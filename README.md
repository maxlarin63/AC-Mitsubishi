# Mitsubishi AC Modbus QuickApp for Fibaro HC3

Fibaro HC3 QuickApp that controls and monitors Mitsubishi air conditioning via **Modbus RTU over TCP**. It talks to a **MelcoBEMS MINI (A1M)** interface through a **USR-TCP232-24** serial-to-Ethernet converter.

---

## Hardware block diagram

```
┌─────┐      ┌──────────────────┐      ┌─────────────────┐      ┌──────────────────────┐
│ HC3 │◄────►│  Ethernet switch │◄────►│  USR-TCP232-24  │◄────►│ MelcoBEMS MINI (A1M) │
└─────┘      └──────────────────┘      │ (serial↔TCP)    │      │   (AC interface)     │
                                       └─────────────────┘      └──────────────────────┘
```

- **HC3** — Fibaro Home Center 3 (runs the QuickApp).
- **Ethernet switch** — LAN connection between HC3 and the converter.
- **USR-TCP232-24** — Converts Modbus RTU on serial to TCP; HC3 connects to its IP:port.
- **MelcoBEMS MINI (A1M)** — Mitsubishi BEMS adapter; connects to the AC unit and exposes Modbus registers.

---

## Functionality

### Monitoring (read)

The QuickApp periodically **polls** the MelcoBEMS (every 60 seconds) and updates the UI:

| Data           | Description                    |
|----------------|--------------------------------|
| Room temp      | Current room temperature (°C)  |
| Setpoint       | Target temperature (°C)        |
| Power          | ON / OFF                       |
| Mode           | Heat, Dry, Cool, Vent, Auto    |
| Fan speed      | Auto, Quiet, Weak, Strong, V.Strong |
| Vane position  | Auto, Pos1–5, Swing            |

A manual **Update** button triggers an immediate poll. Overlapping updates are serialized to avoid connection conflicts.

### Control (write)

Sending commands opens a TCP connection, sends a Modbus write, then triggers a refresh:

- **Power** — On / Off
- **Mode** — Auto, Heat, Dry, Fan, Cool
- **Setpoint** — Plus / Minus (step 0.5 °C)
- **Fan speed** — Quiet, Weak, Strong, Very Strong
- **Vane** — Position 1–4, Auto

Modbus uses **function code 0x06** (write single register), **CRC16**, and device address **0x01**.

### Technical details

- **Protocol:** Modbus RTU frame over TCP (no MBAP header); CRC16 on every frame.
- **QuickApp variables:**
  - `device_ip` — USR-TCP232-24 IP (default `10.0.1.4` if unset).
  - `device_port` — TCP port (default `4001` if unset).
  - `debug` — Set to `true`, `1`, or `yes` to enable debug log lines (hex dumps, update steps). Omit or set to `false`/`0` to reduce log noise.

---

## Setup

1. Install the QuickApp on the HC3 and set **device_ip** and **device_port** to the USR-TCP232-24 IP and port. Optionally set **debug** to `true` or `1` to enable verbose debug output in the log.
2. Ensure the USR-TCP232-24 is configured for Modbus RTU (baud, parity, etc.) to match the MelcoBEMS MINI (A1M).
3. Wire: HC3 and USR-TCP232-24 on the same LAN; USR-TCP232-24 serial to MelcoBEMS MINI; MelcoBEMS to the Mitsubishi AC.

---

## Building

The `.fqa` package is built with the [fqa](https://github.com/maxlarin63/fqa) tool (pack Fibaro QuickApp from project layout).

- **CI:**
  - Push a tag `v*` to build and attach the `.fqa` to a GitHub Release, or run the **Build FQA** workflow manually and download the artifact.
  - The workflow should check out a tagged fqa release (e.g. `ref: v1.0.0`) so CI and local builds use the same tool version.
- **Local (direct fqa):**
  - Clone the fqa repo.
  - From this repo run: `python /path/to/fqa/fqa.py pack .` (output: `AC Mitsubishi.fqa` in the current directory).
  - To see which fqa version you are using, run `python /path/to/fqa/fqa.py --version` (or `fqa --version` if installed on PATH).
- **Local (via `fqa-pack` from this project):**
  - Make sure `.fqa-tool-path` points to your `fqa` command (for example: `python "D:\HomeAutomation\fqa\fqa.py"`).
  - From this repo run:
    - `python fqa-pack.py -y -o dist` (cross‑platform), or
    - `fqa-pack.bat -y -o dist` on Windows.
  - The built `.fqa` will be placed under `dist\`.

---

## Credits

- Created for **Indome.ee / Kuuno**
- Refactored for readability and maintainability
