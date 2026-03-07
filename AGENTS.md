# AGENTS.md

## Cursor Cloud specific instructions

This is a **Fibaro HC3 QuickApp** (Lua 5.3) for controlling Mitsubishi AC units via Modbus RTU over TCP. It is an embedded IoT firmware plugin, not a web application.

### Project overview

- Single source file: `main.lua`
- Build tool: [fqa](https://github.com/maxlarin63/fqa) v1.0.0 (Python CLI, cloned to `/opt/fqa`)
- Output: `.fqa` JSON package deployable to Fibaro HC3 hardware
- No automated test suite exists (CI `test.yml` is a placeholder)
- No linter is configured; use `luac5.3 -p main.lua` for Lua syntax checking

### Build

```sh
fqa-pack --yes -o "AC Mitsubishi.fqa" .
```

Or directly:

```sh
python3 /opt/fqa/fqa.py pack --yes -o "AC Mitsubishi.fqa" .
```

### Lint (syntax check)

```sh
luac5.3 -p main.lua
```

### Key caveats

- The `fqa` package is **not on PyPI**. It must be cloned from GitHub (`v1.0.0` tag) and used via `python3 /opt/fqa/fqa.py`. A wrapper script at `/usr/local/bin/fqa-pack` forwards to `fqa.py pack`.
- End-to-end testing requires physical Fibaro HC3 hardware + USR-TCP232-24 + MelcoBEMS MINI + Mitsubishi AC unit. This cannot be tested in the cloud VM.
- The `.fqa` output is gitignored. Build artifacts should not be committed.
