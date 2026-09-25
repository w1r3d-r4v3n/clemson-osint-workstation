[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$IsoPath,

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9 _.-]{0,63}$')]
    [string]$Name = 'Clemson-OSINT',

    [ValidateRange(4096, 16384)]
    [int]$MemoryMB = 6144,

    [ValidateRange(2, 8)]
    [int]$CpuCount = 4,

    [ValidateRange(50, 256)]
    [int]$DiskGB = 80,

    [string]$VmRoot = (Join-Path $env:USERPROFILE 'VirtualBox VMs'),

    [switch]$NoStart
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Find-VBoxManage {
    $command = Get-Command 'VBoxManage.exe' -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $candidate = Join-Path $env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'
    if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    throw 'VBoxManage.exe was not found. Install the Oracle VirtualBox 7.x base package first.'
}

function Invoke-VBox {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
    & $script:VBoxManage @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "VBoxManage failed (exit $LASTEXITCODE): $($Arguments -join ' ')"
    }
}

$VBoxManage = Find-VBoxManage
$resolvedIso = (Resolve-Path -LiteralPath $IsoPath).Path
$isoItem = Get-Item -LiteralPath $resolvedIso
if ($isoItem.Extension -ne '.iso') { throw 'IsoPath must point to an .iso file.' }

$existing = & $VBoxManage list vms
if ($LASTEXITCODE -ne 0) { throw 'Could not list existing VirtualBox machines.' }
if ($existing -match ('"' + [regex]::Escape($Name) + '"')) {
    throw "A VirtualBox machine named '$Name' already exists. This script will not modify or replace it."
}

New-Item -ItemType Directory -Force -Path $VmRoot | Out-Null
$vmFolder = Join-Path $VmRoot $Name
$diskPath = Join-Path $vmFolder "$Name.vdi"

Write-Host "Creating $Name with NAT and host-integration features disabled..."
Invoke-VBox createvm --name $Name --ostype Ubuntu_64 --basefolder $VmRoot --register

try {
    Invoke-VBox modifyvm $Name `
        --memory $MemoryMB --cpus $CpuCount --cpu-profile host `
        --firmware efi --graphicscontroller vmsvga --vram 128 --accelerate-3d off `
        --nic1 nat --cable-connected1 on `
        --clipboard-mode disabled --drag-and-drop disabled `
        --audio-enabled off --usb-ohci off --usb-ehci off --usb-xhci off `
        --rtc-use-utc on

    Invoke-VBox createmedium disk --filename $diskPath --size ($DiskGB * 1024) --format VDI --variant Standard
    Invoke-VBox storagectl $Name --name 'SATA' --add sata --controller IntelAhci --portcount 3 --bootable on
    Invoke-VBox storageattach $Name --storagectl 'SATA' --port 0 --device 0 --type hdd --medium $diskPath --nonrotational on
    Invoke-VBox storageattach $Name --storagectl 'SATA' --port 1 --device 0 --type dvddrive --medium $resolvedIso
    Invoke-VBox modifyvm $Name --boot1 dvd --boot2 disk --boot3 none --boot4 none

    $hash = Get-FileHash -LiteralPath $resolvedIso -Algorithm SHA256
    Write-Host "ISO SHA-256: $($hash.Hash)"
    Write-Host 'Compare that value with the SHA256SUMS file published by Ubuntu before entering credentials.'

    if (-not $NoStart) {
        Invoke-VBox startvm $Name --type gui
        Write-Host 'The Ubuntu installer is open. Complete it interactively; do not enable automatic login.'
    }
    else {
        Write-Host "VM created but not started: $Name"
    }
}
catch {
    Write-Warning "The VM was created but configuration stopped: $($_.Exception.Message)"
    Write-Warning "Inspect it with: & '$VBoxManage' showvminfo '$Name'"
    throw
}

Write-Host ''
Write-Host 'Security settings applied:'
Write-Host '  Network: NAT (no host port forwarding)'
Write-Host '  Clipboard and drag/drop: disabled'
Write-Host '  Shared folders: none'
Write-Host '  USB, audio, and 3D acceleration: disabled by default'
Write-Host 'After Ubuntu is installed, power off and eject the ISO from Settings > Storage.'
