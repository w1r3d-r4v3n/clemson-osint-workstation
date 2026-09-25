[CmdletBinding()]
param(
    [string]$Name = 'Clemson-OSINT'
)

$ErrorActionPreference = 'Stop'
$command = Get-Command 'VBoxManage.exe' -ErrorAction SilentlyContinue
if ($command) { $vbox = $command.Source }
else { $vbox = Join-Path $env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe' }
if (-not (Test-Path -LiteralPath $vbox -PathType Leaf)) { throw 'VBoxManage.exe was not found.' }

$lines = & $vbox showvminfo $Name --machinereadable
if ($LASTEXITCODE -ne 0) { throw "VirtualBox VM not found: $Name" }
$settings = @{}
foreach ($line in $lines) {
    if ($line -match '^([^=]+)="?(.*?)"?$') { $settings[$matches[1]] = $matches[2].TrimEnd('"') }
}

$checks = @(
    @{ Label = 'NIC 1 uses NAT'; Pass = $settings['nic1'] -eq 'nat'; Value = $settings['nic1'] },
    @{ Label = 'Clipboard is disabled'; Pass = $settings['clipboard'] -eq 'disabled'; Value = $settings['clipboard'] },
    @{ Label = 'Drag and drop is disabled'; Pass = $settings['draganddrop'] -eq 'disabled'; Value = $settings['draganddrop'] },
    @{ Label = '3D acceleration is disabled'; Pass = $settings['accelerate3d'] -eq 'off'; Value = $settings['accelerate3d'] },
    @{ Label = 'No host port-forwarding rules'; Pass = -not ($settings.Keys -match '^Forwarding'); Value = (($settings.Keys -match '^Forwarding') -join ',') },
    @{ Label = 'No shared folders'; Pass = -not ($settings.Keys -match '^SharedFolderNameMachineMapping'); Value = (($settings.Keys -match '^SharedFolderNameMachineMapping') -join ',') }
)

$failed = 0
foreach ($check in $checks) {
    if ($check.Pass) { Write-Host "PASS  $($check.Label)" -ForegroundColor Green }
    else { Write-Host "FAIL  $($check.Label) [$($check.Value)]" -ForegroundColor Red; $failed++ }
}

if ($failed -gt 0) { throw "$failed isolation check(s) failed." }
Write-Host 'All host-side isolation checks passed.'
