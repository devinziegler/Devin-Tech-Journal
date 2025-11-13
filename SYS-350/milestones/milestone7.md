# Milestone 7

## Overview

* **Explore `cmdlets` for HyperV**
* **clone Script**
* **Comparison to vCenter**

## Basic HyperV cmdlets

These commands are basic but help build a good foundation of how scripting in powershell for HyperV will look like. 

This script stops a VM, takes a named snapshot & changes the network adapeter:

```ps1
# Stop sonofubuntu
Stop-VM -Name sonofubuntu

# Create Checkpoint for sonofubuntu
Set-VM -Name sonofubuntu -CheckpointType Standard
Checkpoint-VM -Name sonofubuntu
Start-Sleep -Seconds 10
...
```
> Full Script [here](https://github.com/devinziegler/Devin-Tech-Journal/blob/main/SYS-350/HyperV-Automation/sonofubuntu.ps1)

**I again want to rave about Microsofts documentation for powershell and HyperV, without which I could not have completed any of this: [here](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/overview)**

## Cloning with Powershell

This script takes an existing VM, changes its VHD to read only, creates a new VHD based off the parent, then creates a new VM with the child VHD. 
```ps1
# Path to VM VHD
$parentvhd = Get-Item "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\alpine01-super26.vhdx"

# Change the VHD to Read Only
 $parentvhd.Attributes = $parentvhd.Attributes -bor [System.IO.FileAttributes]::ReadOnly
...
```
> Full Script [here](https://github.com/devinziegler/Devin-Tech-Journal/blob/main/SYS-350/HyperV-Automation/cloner.ps1)

## Comparison to vCenter

Overall, I find the HyperV GUI to be more clunky and less intuative, even though it shares many similarites with vCenter. 

**However**

Automating tasks with powershell was *much* more straight forward and better documented then pyvmomi.




