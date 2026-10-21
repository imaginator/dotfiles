---
name: k8s-cluster
description: 'Interact with the bunker-k3s Kubernetes cluster: plan/dry-run/apply changes via kustomize with server-side apply, inspect and debug workloads (logs, events, describe), exec and port-forward, explore resource graphs, and debug service log files by SSHing to the node. Use when asked to apply manifests, check pods, troubleshoot a service, view node logs, or explore k8s resources. Strict safety: plan and get approval before any write.'
argument-hint: 'e.g. "apply the homeassistant changes" or "why is frigate crash-looping"'
---

# Kubernetes Cluster Interaction (bunker-k3s)

## When to Use

- Applying manifest changes from a Git repo to the cluster
- Inspecting/debugging workloads: pods, deployments, events, logs
- Exec into pods, port-forward to services
- Exploring what exists: resources, ingresses, PVCs, object graphs
- Debugging a service's **log files on the node** via SSH (files not exposed through `kubectl logs`)

Not for: OS-level Ansible changes (use the repo's Ansible workflow), or clusters other than `bunker-k3s`.

## Before starting — check the workspace

The constants and conventions below (`bunker-k3s`, kustomize layout, `/srv/k8s/pv/` paths) come from the homelab k8s repo. **If the current workspace is a different repo, read its `AGENTS.md` (or equivalent) first** and follow that repo's context names, apply conventions, and safety rules — they supersede this skill. If no such file exists, use the defaults below but say so.

## Constants

```bash
CTX=bunker-k3s          # always pass explicitly: kubectl --context bunker-k3s ...
NS_HINT="namespace from the resource's kustomization/Namespace.yaml"
```

- **Never change the kube context globally.** Pass `--context bunker-k3s` on every command.
- **Never talk to any cluster that is not `bunker-k3s`.**
- SSH to nodes: `export SSH_AUTH_SOCK=/run/user/1000/gcr/.ssh && ssh bunker ...` (plain `ssh bunker.imagilan` fails; the gcr agent socket holds the key).

## Safety Rules (strict — AGENTS.md policy)

**Reads are always free.** `get`, `describe`, `logs`, `events`, `top`, `explain`, `diff`, `port-forward`, `exec` (read-only) need no approval.

**Every write requires a plan and explicit user approval first.** A plan must state:

1. Files to change
2. Exact apply command(s)
3. Exact verify command(s)
4. Blast radius (hosts, namespaces, PVCs)
5. Rollback (`git checkout -- <files>` then re-apply)

After presenting the plan, **stop and ask with a structured question** offering exactly:

- **Apply** — run the apply command, then the verify commands
- **Dry-run only** — run `diff`/`--dry-run=server` and report, no mutation
- **Abort** — do nothing, leave the repo untouched

Do not proceed on partial or ambiguous answers; if the user replies with something else, treat it as a new plan to revise.

**Never do these unless the user names the action in their message:**

- `kubectl delete namespace` or delete CRDs
- Delete PVCs / PVs / snapshots or anything holding media/photos/backups
- Change ingress controller, MetalLB, kube-vip, CoreDNS, cert-manager, or default StorageClass while also changing an app
- Apply a whole playbook + entire cluster overlay in one go (unless asked to bootstrap)
- `git commit` (unless asked)

Prefer scale-to-zero over delete. Prefer add/change over rewrite. Max **three apply attempts** before stopping to explain the failure.

## 1. Apply Workflow

Always this order: **plan → dry-run → apply → verify**.

### Apply — kustomize only, server-side

```bash
# Standard: every apply is server-side with force-conflicts
kubectl --context bunker-k3s apply -k deployments/<app>/ --server-side --force-conflicts
```

Rules:

- **Never** `kubectl apply -f <raw-file>` on a file not in a kustomization — add it to the nearest `kustomization.yaml` first. Everything must carry `app.kubernetes.io/managed-by: kustomize`.
- **helmCharts / remote bases**: `kubectl apply -k` doesn't support `--enable-helm`, so render first, then pipe:

  ```bash
  kustomize --enable-helm deployments/<dir> | kubectl --context bunker-k3s apply --server-side --force-conflicts -f -
  ```

- Use the smallest command matching the change (one deployment, not the whole overlay) when the repo structure allows scoping.

### Dry-run first

```bash
kubectl --context bunker-k3s diff -k deployments/<app>/          # shows live vs desired
kubectl --context bunker-k3s apply -k deployments/<app>/ --dry-run=server
```

`diff` exits 1 when there are differences — that's expected, not an error. Show the user the diff before applying.

### Verify after apply

```bash
kubectl --context bunker-k3s get <kind> -n <ns>
kubectl --context bunker-k3s status deploy/<name> -n <ns>
kubectl --context bunker-k3s describe <kind>/<name> -n <ns>
kubectl --context bunker-k3s logs deploy/<name> -n <ns> --tail=80
```

**Done means**: desired pods Running/Ready, PVC Bound if applicable, no looping events (CrashLoopBackOff, ImagePullBackOff, FailedMount, FailedScheduling), and — if there's an ingress — curl the hostname (don't invent `-k` unless the service is known HTTP-only).

On failure: **events and logs first**, then fix the repo, then re-apply. If you can't tell whether it worked, say so — don't call it done.

## 2. Inspect & Debug

### Triage a broken pod

```bash
kubectl --context bunker-k3s get pods -n <ns>                       # status overview
kubectl --context bunker-k3s describe pod <pod> -n <ns>             # events at bottom: mounts, scheduling, probes
kubectl --context bunker-k3s logs <pod> -n <ns> --tail=100          # current container
kubectl --context bunker-k3s logs <pod> -n <ns> --previous --tail=100   # crashed container
kubectl --context bunker-k3s get events -n <ns> --sort-by=.lastTimestamp
```

Read `describe` events bottom-up: `FailedScheduling` → node/resources; `FailedMount` → PV/PVC/secret names; `Unhealthy` → probe config vs actual port/path; `OOMKilled` → memory limits.

### Log patterns

```bash
kubectl --context bunker-k3s logs deploy/<name> -n <ns> --tail=200 | grep -iE 'error|warn|fail'
kubectl --context bunker-k3s logs -n <ns> -l app=<label> --all-containers --prefix   # multi-pod
kubectl --context bunker-k3s logs deploy/<name> -n <ns> --since=15m
```

### Resource usage

```bash
kubectl --context bunker-k3s top pods -n <ns> --sort-by=memory
kubectl --context bunker-k3s top nodes
```

## 3. Exec / Port-Forward

```bash
kubectl --context bunker-k3s exec -n <ns> deploy/<name> -- sh -c 'ls /data'
kubectl --context bunker-k3s exec -it -n <ns> deploy/<name> -- bash    # if shell exists
kubectl --context bunker-k3s port-forward -n <ns> svc/<name> 8080:80   # local 8080 → svc 80
```

- Prefer `sh` over `bash` (slim images often lack bash).
- `exec` is a write-capable channel — interactive use is fine, but destructive commands inside (`rm`, DB writes) follow the same approval rule as cluster writes.
- Port-forward runs in the foreground; use background execution when you need to curl against it in the same session.

## 4. Explore Resources

```bash
kubectl --context bunker-k3s get all -n <ns>
kubectl --context bunker-k3s get ingress,pvc,configmap,secret -n <ns>
kubectl --context bunker-k3s get deploy -A                      # survey cluster
kubectl --context bunker-k3s explain pod.spec.containers        # schema lookup
```

Trace an app's object graph: `Deployment → ReplicaSet → Pod → containers/image`; `Ingress → Service → endpoints` (`kubectl get endpoints -n <ns>` — empty endpoints = selector/port mismatch); `PVC → PV → StorageClass`.

For a full picture of one app, read its kustomization directory in the repo first — manifests are the source of truth, the cluster is the applied state.

## 5. Node Log Files via SSH

Some services write log **files** inside hostPath PVs or containers that `kubectl logs` can't reach (e.g. app logfiles under `/srv/k8s/pv/<app>/`). Debug them by SSHing to **`bunker`** — the only node this skill covers for log debugging:

```bash
export SSH_AUTH_SOCK=/run/user/1000/gcr/.ssh
ssh bunker 'sudo tail -100 /srv/k8s/pv/<app>/logs/app.log'
ssh bunker 'sudo ls -lh /srv/k8s/pv/<app>/'                        # find what's there first
```

Guidelines:

- **Locate first**: check the app's `PersistentVolume.yaml` in the repo for the hostPath (`/srv/k8s/pv/...`) before guessing paths.
- `sudo` is often needed (root-owned PV dirs). If sudo prompts for a password, stop and tell the user to run it themselves — never attempt to supply passwords.
- Tail/grep with limits (`tail`, `grep -c`, `wc -l`) — never cat a multi-GB log into the session.
- To find which pod writes the file: match the PV mount in the pod spec (`kubectl get pod <p> -n <ns> -o jsonpath='{...volumeMounts}'`), then correlate with `kubectl logs` for the live stream.
- One-off commands only; for repeatable checks, propose adding a script to the repo instead of ad-hoc chains.

## Completion Checks

- **Apply**: diff shown, apply ran, verify commands passed, diff limited to the requested service, no secrets in diff or chat, leftover manual steps stated (DNS, reboot, port-forward).
- **Debug**: root cause identified with evidence (event line or log excerpt), or an explicit "couldn't determine it" — never claim success on a guess.
- **Explore**: concrete resource list with names/namespaces, not raw JSON dumps.
- **Node logs**: path confirmed from the PV spec, output truncated sensibly.