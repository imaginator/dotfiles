Wireplumber has the nastiest syntax parsing error reporting

```
systemctl --user stop  wireplumber.service  && rm -r ~/.local/state/wireplumber && systemctl --user start wireplumber
```

checking it picks up the configs
```
journalctl --user -u wireplumber -f  | grep rules
```

for checking files with bad formatting
```
journalctl --user -u wireplumber -f  | grep "has no value"
```

