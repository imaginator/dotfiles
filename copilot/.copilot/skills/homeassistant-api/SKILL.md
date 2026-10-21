---
name: homeassistant-api
description: 'Interact with Home Assistant over its REST API: read entity states, call services, query history/logbook, find entities and the automations that use them. Use when asked about Home Assistant states, entities, automations, turning things on/off, or analyzing HA history. Requires HA_URL and HA_TOKEN env vars.'
argument-hint: 'e.g. "what is the state of sensor.x" or "turn on the kitchen lights"'
---

# Home Assistant REST API

## When to Use

- Read the current state of one or more entities
- Call Home Assistant services (turn on/off, set temperature, run scripts…)
- Query history or logbook for an entity or domain
- Explore entities: filter by domain, area, device, or name
- Find which automations/scripts reference an entity
- Diagnose why something is or isn't automating (state + history + automation config)

Do **not** use this skill for managing the HA deployment itself (pods, ingress) — that is normal `kubectl` work against the `homeassistant` namespace.

## Prerequisites

One environment variable must be set at runtime (never hardcode, never commit):

- `HA_TOKEN` — a Home Assistant **long-lived access token** (Profile → Security → Long-lived tokens)

`HA_URL` is **`https://ha.imaginator.com`** (bunker-k3s, DNS → `bunker.dyndns.imaginator.com`, direct — no Cloudflare tunnel). Override via the `HA_URL` env var if it ever moves.

If `HA_TOKEN` is missing, stop and ask the user to export it in the terminal. Never print the token.

```bash
HA_URL=${HA_URL:-https://ha.imaginator.com}
: "${HA_TOKEN:?set HA_TOKEN}"
HA=(-H "Authorization: Bearer $HA_TOKEN" -H "Content-Type: application/json")
```

## Core Endpoints

All endpoints are under `$HA_URL/api`. Responses wrap payloads in a `result` key for most endpoints (states returns a bare array).

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/` | Health check, returns `{"message": "API running."}` |
| GET | `/api/states` | All entity states (bare JSON array) |
| GET | `/api/states/<entity_id>` | One entity |
| POST | `/api/services/<domain>/<service>` | Call a service; body = service data |
| GET | `/api/history/period/<start>?filter_entity_id=…&end=…&minimal_response` | History |
| GET | `/api/logbook/<start>?end=…&entity=…` | Logbook entries |
| GET | `/api/template` | Render a Jinja2 template (POST body `{"template": …}`) |
| GET | `/api/config` | HA config summary (location, version, allowlist) |
| GET | `/api/states/<entity_id>/attributes/<attribute>` | Single attribute |
| GET | `/api/calendars/<calendar_id>?start=…&end=…` | Calendar events |

Timestamps are ISO 8601 in the **local HA timezone**, e.g. `2026-10-22T08:00:00+02:00`. Relative times like `today` are NOT accepted — compute absolute timestamps (e.g. with `date -d '1 day ago'`).

## Standard Queries

### Read states

```bash
# One entity
curl -sf "${HA[@]}" "$HA_URL/api/states/sensor.outdoor_temperature"

# All states, filtered to a domain (jq)
curl -sf "${HA[@]}" "$HA_URL/api/states" | jq '[.[] | select(.entity_id | startswith("light."))]'
```

A state object looks like:

```json
{
  "entity_id": "light.kitchen",
  "state": "on",
  "attributes": {"brightness": 180, "friendly_name": "Kitchen", "device_class": null},
  "last_changed": "2026-10-22T07:58:12.003+02:00",
  "last_updated": "2026-10-22T07:58:12.003+02:00"
}
```

Notes:
- `state` is always a **string** (`"23.5"`, `"unavailable"`, `"unknown"`).
- `last_changed` only moves when `state` changes; `last_updated` moves on any update including attributes.
- Unavailable/unknown states usually mean the device is offline or integration is reconnecting — check `last_changed` to see how long.

### Call a service

```bash
curl -sf "${HA[@]}" -X POST "$HA_URL/api/services/light/turn_on" \
  -d '{"entity_id": "light.kitchen", "brightness_pct": 80}'
```

- The response is the list of **affected states after the call** — use it to confirm the change took effect.
- Common services: `light/turn_on|turn_off|toggle`, `switch/turn_on|turn_off`, `climate/set_temperature`, `homeassistant/turn_on|turn_off`, `automation/trigger`, `script/turn_on`, `notify/<service>`.
- Service data keys vary per service — check Developer Tools → Services in the UI, or `GET /api/services` to list all services and their fields.

### History

```bash
START=$(date -d '6 hours ago' --iso-8601=seconds)
curl -sf "${HA[@]}" "$HA_URL/api/history/period/$START?filter_entity_id=sensor.power&minimal_response"
```

- Returns `[[state, state, …]]` — one array per requested entity.
- `minimal_response` omits attributes (fast, small); add `&no_attributes` too.
- Long ranges: add `&max_age=7d` or expect large payloads. Always pipe through `jq` — never dump raw history to chat.

### Logbook

```bash
START=$(date -d '1 hour ago' --iso-8601=seconds)
curl -sf "${HA[@]}" "$HA_URL/api/logbook/$START?entity=automation.lights_on"
```

Shows *why* things happened: triggers, service calls, automation runs — the first stop when debugging "did the automation fire?".

### Render a template (powerful for analysis)

```bash
curl -sf "${HA[@]}" -X POST "$HA_URL/api/template" \
  -d '{"template": "{{ states.sensor | selectattr(\"state\", \"equalto\", \"unavailable\") | map(attribute=\"entity_id\") | list }}"}'
```

Templates run server-side with full HA Jinja context — ideal for cross-entity queries the REST API can't express.

## Entity & Automation Analysis

### Find entities

```bash
# By name fragment (search id + friendly_name)
curl -sf "${HA[@]}" "$HA_URL/api/states" \
  | jq -r '.[] | select((.entity_id + " " + (.attributes.friendly_name // "")) | test("kitchen"; "i")) | .entity_id'

# Count per domain
curl -sf "${HA[@]}" "$HA_URL/api/states" | jq -r '.[].entity_id | split(".")[0]' | sort | uniq -c | sort -rn
```

### Find which automations use an entity

Try in order, stop at the first that works:

1. **WebSocket API** (same token) — the authoritative source for automation config:

   ```bash
   # needs a ws client, e.g. websocat (same token, no other auth)
   # send: {"id":1,"type":"auth","access_token":"$HA_TOKEN"}
   # then: {"id":2,"type":"config/automation/config","automation_id":"<id>"}
   # list ids via {"id":3,"type":"config/automation/list"}
   ```

   If `websocat` (or another ws client) is not installed, skip to step 3 rather than installing tools unprompted.

2. **REST states** — `GET /api/states` and inspect `automation.*` entities; `attributes` only contains the config if the automation was edited in YAML mode, so this often comes up empty.

3. **Config repo grep** — if the user has a Git-synced HA config checkout (or the PV at `/srv/k8s/pv/homeassistant` is mounted/readable), grep it directly:

   ```bash
   grep -rl 'sensor\.power_meter' /path/to/ha-config/automations/ /path/to/ha-config/packages/
   ```

   Ask the user where the config lives if it isn't obvious — do not read the PV without asking.

### Diagnose an automation

1. `GET /api/states/automation.<slug>` — is it enabled (`state: on`)? Check `last_triggered`.
2. `GET /api/logbook/<start>?entity=automation.<slug>` — did it fire recently?
3. `GET /api/history/period/<start>?filter_entity_id=<trigger_entity>` — was the trigger entity in the expected state at that time?
4. If it never fires: check trigger conditions against actual states (e.g. sun position, time windows, `for:` durations need the state to persist).

## Safety Rules

- **Reads are free; writes need care.** GET requests are always safe. POST service calls change the physical world — **confirm with the user before** calling services on security/safety devices: `lock.*`, `alarm_control_panel.*`, `cover.*` (open/close), `siren.*`, `vacuum.*`, `climate.*` away-mode changes, and anything that cuts power (`switch.*` on servers/Pi/network gear if identifiable). Routine calls (`light.*`, `media_player.*`, `fan.*`, `input_boolean.*`, `automation/trigger`, `script/turn_on`) execute directly and report the result.
- Batch reads: prefer one `GET /api/states` + local `jq` over N individual calls.
- Pipe large outputs (states, history) through `jq` — never paste raw JSON dumps into chat.
- Never echo `HA_TOKEN`, never write it into files in a repo.
- Rate limiting: keep request bursts modest; this is a home system, not a public API.

## Completion Checks

- State queries: report `entity_id`, `state`, and relevant attributes (with units), plus `last_changed` if staleness matters.
- Service calls: show the returned state to confirm the effect, or say clearly that it failed.
- Analysis: give counts and concrete entity lists, not raw dumps.