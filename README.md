# EVE-NG terminal integration for Windows 11

Make EVE-NG open **SecureCRT** (or **PuTTY**) when you click a node, instead of
whatever is wired up by default. Two small PowerShell scripts, per-user registry
(`HKCU`), no administrator rights.

## How it works

With EVE-NG in **Native console** mode, clicking a node opens a `telnet://host:port`
(or `ssh://`) URL. Windows hands that URL to whatever application owns the protocol.
These scripts repoint the `telnet://` and `ssh://` handlers at the terminal you want.

## Requirements

- EVE-NG **Windows Client Integration Pack** installed.
- SecureCRT and/or PuTTY installed.
- In the EVE-NG web UI: your user menu -> **Console -> Native console**.

## Usage

```powershell
# Use SecureCRT:
powershell -ExecutionPolicy Bypass -File .\Set-EVE-SecureCRT.ps1

# Use PuTTY (or to revert):
powershell -ExecutionPolicy Bypass -File .\Set-EVE-PuTTY.ps1
```

Each script auto-detects the terminal's `.exe`. If it cannot find it, pass the path:

```powershell
.\Set-EVE-SecureCRT.ps1 -SecureCRTPath "C:\Program Files\VanDyke Software\SecureCRT\SecureCRT.exe"
.\Set-EVE-PuTTY.ps1     -PuttyPath     "C:\Program Files\PuTTY\putty.exe"
```

## Test

```powershell
Start-Process "telnet://127.0.0.1:23"
```

The chosen terminal should launch (the connection itself failing is fine). Then in
EVE-NG, click a node; allow the browser to open the app the first time.

## Revert to default

```powershell
Remove-Item -Path "HKCU:\Software\Classes\telnet" -Recurse -Force
Remove-Item -Path "HKCU:\Software\Classes\ssh"    -Recurse -Force
```

## License

MIT. See [LICENSE](LICENSE).
