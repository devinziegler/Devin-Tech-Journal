# Milestone 4

## Overview 🌍
* **Nested ESXI Appliance**

## Network Diagram
![Network Diagram](https://github.com/devinziegler/Devin-Tech-Journal/blob/main/SYS-350/out/SYS-350/FreemanNetwork.png)
> PlantUML found [here](https://github.com/devinziegler/Devin-Tech-Journal/blob/main/SYS-350/network.plantuml)

## Deploying and OVF
1. In vsphere click `actions/deploy ovf template`
2. Customize settings as needed for the machine

## Nested ESXI

**Configure Networking for nested virtual networking**
```
Promiscuous mode: Accept
Forged transmits: Accept
```

# Part 2
**Configuring DHCP**

To configure DHCP on AD, run the following command to install DHCP:
```ps1
Install-WindowsFeature DHCP -IncludeManagementTools
```

The the server must be authorized with the following:
```
Add-DhcpServerInDC -DnsName dc1-devin.devin.local -IPAddress 10.0.17.4
```

DHCP scope can be configured through GUI or powershell, the GUI is straight forward, if configuring by powershell Microsoft has some very in depth documentation:
* [Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/networking/technologies/dhcp/quickstart-install-configure-dhcp-server?tabs=gui)

## Making a VM template
* Right click VM in `vSphere`
* Click `convert to template`
> Make sure VM tools are installed on machine before converting to template!

## VM Customization Specifications
Customization specifications allow for Guest OS configuration before startup. Apply the specification when cloning from a template for the specifications to take affect.

