# Milestone 6

## Overview 

* **Installing HyperV**
* **HyperV Network Config**
* **Installing WAC**
* **Firewall Config (PFSense)**
* **Importing A Host**

## Installing HyperV
To Install HyperV on Windows Server 2019 Run the following commands in an administrator command prompt:
```ps1
Install-WindowsFeature -Name Hyper-V -ComputerName <computer_name> -IncludeManagementTools -Restart
```
Test the feature was installed using the following:
```ps1
Get-WindowsFeature Hyper-V -ComputerName <computer_name>
```
> Find More Resources For HyperV at [Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/install-hyper-v?tabs=powershell&pivots=windows-server).

## Hyper V Network Configuration

When Creating a new VSwitch, we must firt take down the network adapter that is being used for the host:
```ps1
Get-NetAdapter
```
> In my case this was adapter 8

Now a WAN vswitch is needed run the following:
```ps1
New-VMSwitch -Name HyperV-WAN -NetAdapterName "Ethernet 8"
```
> Make sure the Net Adapter matches the one from the output of `Get-NetAdapter`

Now A lan Switch is needed to complete the network, it is much the same however a adapter is not needed:
```ps1
New-VMSwitch -Name LAN-INTERNAL -SwitchType Internal
```
> Again These steps can be found in more detail at [Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines?tabs=powershell&pivots=windows-server).

## Installing `WAC`

`WAC` or `Windows Admin Center` can be installed from a browser or `wget` from powershell:
```ps1
wget https://aka.ms/WACDownload
```
> If Downloading from IE, make sure internet downloads are available [help](https://docs.rackspace.com/docs/enable-file-downloads-in-internet-explorer)

## PFSense Configuration

PFSense Configuration has already been covered a number of times on this wiki

Config [here](https://github.com/devinziegler/Devin-Tech-Journal/wiki/Lab-01-%E2%80%90-Virtual-Firewall-and-Windows-10-Configuration#firewall-setup)
> PFSense also has a web portal where it can be configurated with a GUI, for this lab I chose to use DHCP on the LAN network

## Creating A VM with an existing VHD

This can be down in the HyperV manager however I find it more straight forward to use powershell:
```ps1
# Create the VM
New-VM -Name "wks01-super26" -MemoryStartupBytes 4GB -BootDevice VHD -VHDPath "C:\VM Storage\wks01-super26.vhdx" -Path .\VMData -Generation 2 -Switch "LAN-INTERNAL"
# Disable Secure Boot
Set-VMFirmware -VMName "wks01-super26" -DisableSecureBoot
# Enable TPM
Enable-VMTPM -VMName "wks01-super26"
```
> This is the command is specialized for my use case, file paths will be different for other deployments. 



