<#
    Set-EVE-SecureCRT.ps1
    Hace que EVE-NG (consola "Native") abra SecureCRT para telnet:// y ssh://.
    Registro por usuario (HKCU): NO necesita administrador y tiene prioridad
    sobre el PuTTY que instala el client pack de EVE-NG.

    Uso:
      .\Set-EVE-SecureCRT.ps1
      .\Set-EVE-SecureCRT.ps1 -SecureCRTPath "D:\ruta\SecureCRT.exe"
#>

param(
    [string]$SecureCRTPath
)

$ErrorActionPreference = 'Stop'
Write-Host "== EVE-NG -> SecureCRT ==" -ForegroundColor Cyan

# 1) Localizar SecureCRT.exe
if (-not $SecureCRTPath) {
    $candidates = @(
        "C:\Program Files\VanDyke Software\SecureCRT\SecureCRT.exe",
        "C:\Program Files (x86)\VanDyke Software\SecureCRT\SecureCRT.exe"
    )
    foreach ($ap in @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SecureCRT.exe",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\SecureCRT.exe")) {
        if (Test-Path $ap) {
            $val = (Get-ItemProperty -Path $ap)."(default)"
            if ($val) { $candidates += $val }
        }
    }
    $SecureCRTPath = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}

if (-not $SecureCRTPath -or -not (Test-Path $SecureCRTPath)) {
    Write-Host "No encuentro SecureCRT.exe." -ForegroundColor Yellow
    Write-Host "Ejecuta indicando la ruta, por ejemplo:"
    Write-Host '  .\Set-EVE-SecureCRT.ps1 -SecureCRTPath "C:\Program Files\VanDyke Software\SecureCRT\SecureCRT.exe"'
    exit 1
}

Write-Host ("SecureCRT: {0}" -f $SecureCRTPath) -ForegroundColor Green
$cmd = '"{0}" /T "%1"' -f $SecureCRTPath

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
Write-Host "Prueba rapida (debe lanzar SecureCRT):"
Write-Host '  Start-Process "telnet://127.0.0.1:23"'
Write-Host ""
Write-Host "Para revertir a PuTTY: borra HKCU:\Software\Classes\telnet y HKCU:\Software\Classes\ssh" -ForegroundColor DarkGray
