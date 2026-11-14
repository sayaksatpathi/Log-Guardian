# Export-SecurityEvents.ps1
# Export selected Windows event IDs from a bounded time range.
# Run as Administrator. Output may contain sensitive data: keep it private.

[CmdletBinding()]
param(
    [int]$HoursBack = 24,
    [string]$OutputDirectory = ".\soc-event-export",
    [int[]]$EventIds = @(4624,4625,4634,4647,4672,4688,4720,4722,4725,4728,4732,4740,1102,4104)
)

#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

if ($HoursBack -lt 1 -or $HoursBack -gt 720) {
    throw 'HoursBack must be between 1 and 720.'
}

$since = (Get-Date).AddHours(-$HoursBack)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$events = @()

$channels = @('Security', 'Microsoft-Windows-PowerShell/Operational')
foreach ($channel in $channels) {
    try {
        $found = Get-WinEvent -FilterHashtable @{
            LogName = $channel
            Id = $EventIds
            StartTime = $since
        } -ErrorAction Stop

        foreach ($event in $found) {
            $events += [pscustomobject]@{
                TimeCreated = $event.TimeCreated.ToUniversalTime().ToString('o')
                Computer = $event.MachineName
                Channel = $event.LogName
                Provider = $event.ProviderName
                EventId = $event.Id
                RecordId = $event.RecordId
                Level = $event.LevelDisplayName
                Message = ($event.Message -replace '[\r\n]+', ' ').Trim()
                Xml = $event.ToXml()
            }
        }
    } catch {
        Write-Warning "Could not read $channel : $($_.Exception.Message)"
    }
}

$csvPath = Join-Path $OutputDirectory "security-events-$stamp.csv"
$jsonPath = Join-Path $OutputDirectory "security-events-$stamp.json"
$events | Sort-Object TimeCreated | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csvPath
$events | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 -Path $jsonPath

Write-Host "Exported $($events.Count) events since $since"
Write-Host "CSV:  $csvPath"
Write-Host "JSON: $jsonPath"
Write-Warning 'Review and redact usernames, hostnames, IP addresses, command lines, and tokens before sharing.'
