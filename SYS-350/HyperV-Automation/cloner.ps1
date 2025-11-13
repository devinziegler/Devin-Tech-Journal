# Path to VM VHD
$parentvhd = Get-Item "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\alpine01-super26.vhdx"

# Change the VHD to Read Only
 $parentvhd.Attributes = $parentvhd.Attributes -bor [System.IO.FileAttributes]::ReadOnly

# Create Child VHD
 New-VHD -Path "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\childofalpine.vhdx" -ParentPath $parentvhd -Differencing
$childvhd = Get-Item "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\childofalpine.vhdx"

# Create a new VM with the childofalpine VHD
New-VM -Name childofalpine -MemoryStartupBytes 8GB -BootDevice VHD -VHDPath $childvhd -Path .\VMData -Generation 1 -Switch LAN-INTERNAL

# Set Processor Count & power on
Set-VMProcessor -VMName childofalpine -Count 2
Start-VM -Name childofalpine
Start-Sleep -Seconds 5

# Display new VM details
Get-VM -Name childofalpine