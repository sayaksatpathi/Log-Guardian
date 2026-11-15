#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [string]$ManagerAddress = '127.0.0.1',
    [switch]$SkipAuditPolicy
)

$ErrorActionPreference = 'Stop'
$version = '4.14.10-1'
$agentName = "$env:COMPUTERNAME-Windows"
$msi = Join-Path $env:TEMP "wazuh-agent-$version.msi"
$log = Join-Path $env:TEMP "wazuh-agent-install.log"
$url = "https://packages.wazuh.com/4.x/windows/wazuh-agent-$version.msi"

Write-Host "Checking Wazuh manager enrollment and event ports at $ManagerAddress..."
foreach ($port in 1514, 1515) {
    if (-not (Test-NetConnection -ComputerName $ManagerAddress -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue)) {
        throw "Cannot reach Wazuh TCP port $port at $ManagerAddress. Check the manager and host-only/WSL port forwarding."
    }
}

Write-Host "Downloading the official Wazuh $version Windows agent..."
Invoke-WebRequest -Uri $url -OutFile $msi
$installArgs = @(
    '/i', $msi, '/qn', '/norestart',
    "WAZUH_MANAGER=$ManagerAddress",
    "WAZUH_REGISTRATION_SERVER=$ManagerAddress",
    "WAZUH_AGENT_NAME=$agentName",
    '/l*v', $log
)
$process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $installArgs -Wait -PassThru
if ($process.ExitCode -notin 0, 3010) {
    throw "Wazuh MSI failed with exit code $($process.ExitCode). Installer log: $log"
}

Set-Service -Name WazuhSvc -StartupType Automatic
Start-Service -Name WazuhSvc
if (-not $SkipAuditPolicy) {
    $auditScript = Join-Path $PSScriptRoot 'Enable-SOC-Auditing.ps1'
    if (Test-Path $auditScript) {
        & $auditScript
    } else {
        Write-Warning "Audit script not found beside this installer: $auditScript"
    }
}
Get-Service -Name WazuhSvc | Format-Table Name, Status, StartType
Write-Host "Installer log: $log"
Write-Host "Next: confirm this computer appears Active in Wazuh, then export a bounded Security event window."

