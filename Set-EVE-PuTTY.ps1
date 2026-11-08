<#
    Set-EVE-PuTTY.ps1
    Hace que EVE-NG (consola "Native") abra PuTTY para telnet:// y ssh://.
    Registro por usuario (HKCU): NO necesita administrador.
    (Es la contraparte de Set-EVE-SecureCRT.ps1 / sirve para volver a PuTTY.)

    Uso:
      .\Set-EVE-PuTTY.ps1
      .\Set-EVE-PuTTY.ps1 -PuttyPath "D:\ruta\putty.exe"
#>

param(
    [string]$PuttyPath
)

$ErrorActionPreference = 'Stop'
Write-Host "== EVE-NG -> PuTTY ==" -ForegroundColor Cyan

# 1) Localizar putty.exe
if (-not $PuttyPath) {
    $candidates = @(
        "C:\Program Files\PuTTY\putty.exe",
        "C:\Program Files (x86)\PuTTY\putty.exe",
        "C:\Program Files\EVE-NG\putty.exe",
        "C:\Program Files (x86)\EVE-NG\putty.exe"
    )
    foreach ($ap in @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\putty.exe",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\putty.exe")) {
        if (Test-Path $ap) {
            $val = (Get-ItemProperty -Path $ap)."(default)"
            if ($val) { $candidates += $val }
        }
    }
    $PuttyPath = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}

if (-not $PuttyPath -or -not (Test-Path $PuttyPath)) {
    Write-Host "No encuentro putty.exe." -ForegroundColor Yellow
    Write-Host "Ejecuta indicando la ruta, por ejemplo:"
    Write-Host '  .\Set-EVE-PuTTY.ps1 -PuttyPath "C:\Program Files\PuTTY\putty.exe"'
    exit 1
}

Write-Host ("PuTTY: {0}" -f $PuttyPath) -ForegroundColor Green
# PuTTY entiende directamente la URL telnet://host:port y ssh://host:port
$cmd = '"{0}" "%1"' -f $PuttyPath

# 2) Registrar los manejadores de URL
function Set-UrlHandler([string]$scheme, [string]$desc) {
    $base   = "HKCU:\Software\Classes\$scheme"
    $cmdKey = "$base\shell\open\command"
    New-Item -Path $cmdKey -Force | Out-Null
    New-ItemProperty -Path $base   -Name "(default)"    -Value $desc -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $base   -Name "URL Protocol" -Value ""    -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $cmdKey -Name "(default)"    -Value $cmd  -PropertyType String -Force | Out-Null
    Write-Host ("  {0,-7} -> OK" -f $scheme) -ForegroundColor Green
}

Write-Host "Registrando manejadores (HKCU, sin admin)..."
Set-UrlHandler "telnet" "URL:Telnet Protocol"
Set-UrlHandler "ssh"    "URL:SSH Protocol"

Write-Host ""
Write-Host "Comando asignado:" -ForegroundColor Cyan
Write-Host "  $cmd"
Write-Host ""
Write-Host "En EVE-NG: tu usuario -> Console -> 'Native console', y clica un nodo." -ForegroundColor Cyan
Write-Host "Prueba rapida (debe lanzar PuTTY):"
Write-Host '  Start-Process "telnet://127.0.0.1:23"'
