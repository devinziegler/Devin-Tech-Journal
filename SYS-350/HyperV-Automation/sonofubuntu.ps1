# Stop sonofubuntu
Stop-VM -Name sonofubuntu

# Create Checkpoint for sonofubuntu
Set-VM -Name sonofubuntu -CheckpointType Standard
Checkpoint-VM -Name sonofubuntu
Start-Sleep -Seconds 10

# Rename Checkpoint to snapshot1
Rename-VMCheckpoint -VMName sonofubuntu -Name (Get-VMCheckpoint -VMName "sonofubuntu").Name -NewName "snapshot1"

#start sonofubuntu
Start-VM -Name sonofubuntu

#switch the network adapter
Connect-VMNetworkAdapter -VMName sonofubuntu -SwitchName "LAN-INTERNAL"

Write-Host "Snapshot Name Changed to:"(Get-VMCheckpoint -VMName "sonofubuntu").Name
Write-Host "Network Changed to:"(Get-VMNetworkAdapter -VMName sonofubuntu).SwitchName

