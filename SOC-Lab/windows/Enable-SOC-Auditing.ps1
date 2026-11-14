# Enable-SOC-Auditing.ps1
# Run from an elevated PowerShell session on a disposable Windows lab VM.
# This changes local audit policy to improve SOC telemetry. It does not disable
# security controls. Review organisational policy before use outside a lab.

#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

$subcategories = @(
    'Logon',
    'Logoff',
    'Account Lockout',
    'User Account Management',
    'Security Group Management',
    'Process Creation',
    'Audit Policy Change'
)

Write-Host 'Enabling success and failure auditing for selected subcategories...' -ForegroundColor Cyan
foreach ($subcategory in $subcategories) {
    & auditpol.exe /set "/subcategory:$subcategory" /success:enable /failure:enable
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Could not configure audit subcategory: $subcategory. Check OS language and policy."
    }
}

Write-Host ''
Write-Host 'Current audit policy for selected categories:' -ForegroundColor Green
& auditpol.exe /get /category:*
Write-Host ''
Write-Host 'Optional: enable command-line capture for Event 4688 through Local Group Policy:' -ForegroundColor Yellow
Write-Host 'Computer Configuration > Administrative Templates > System > Audit Process Creation > Include command line in process creation events = Enabled'
Write-Warning 'Process command lines can contain passwords, tokens, and personal data. Use only in an isolated lab and protect/sanitise exports.'
