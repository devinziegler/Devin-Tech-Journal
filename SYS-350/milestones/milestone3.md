# Milestone 3

## Overview 🌍

* **Create DMZ & MGMT Networks**
* **Deploy A webserver in DMZ**
* **Deploy Backup Server on MGMT**
* **Configure firewall for new networks**

## Network Diagram
![Network Diagram](https://github.com/devinziegler/Devin-Tech-Journal/blob/main/out/SYS-350/network/FreemanNetwork.png)

## Creating Networks and Deploying VMs 🛜

**This is covered in a previous milestone:**
* [Milestone 1 Virtual Networking](https://github.com/devinziegler/Devin-Tech-Journal/wiki/Milestone-1#virtual-networking-%EF%B8%8F)

**Allow Firewall Rule for DMZ**
 * a rule will have be be created in pfsense to allow DMZ hosts to have a connection. 
 1. In pfsense web dashboard go to `firewall/rules`
 2. Select New DMZ interface
 3. Add a new rule with the following:
 ```yaml
Action:      Pass
Interface:   DMZ
Protocol:    Any
Source:      DMZ net
Destination: Any
 ```
 > This is a must if you want DMZ hosts to reach the gateway (these rules might change later).


## Deploying a webserver
**Full Configurtaion files for this machine can be found [here](https://github.com/devinziegler/Devin-Tech-Journal/tree/main/SYS-350/web01)**

Since we have configured a webserver before I will lay out the steps here, however the setup can be found above.

 * Configure networking
 * Install apache
 * Start Services
 * Allow apache through firewall

Quick `firewalld` refresher for allowing http:
```bash
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
```
## Configuring Ubuntu Server
**Ubuntu networking is done through netplan, which we have done is the past,[here](https://github.com/devinziegler/Devin-Tech-Journal/wiki/Docker-&-Debian#ubuntu-network-configuration)**

The full netplan file for this sytem can be found here: [backup01-netplan](https://github.com/devinziegler/Devin-Tech-Journal/blob/main/SYS-350/backup01/netplan.yaml)

**Add default pass rule for MGMT**
```yaml
Action:      Pass
Interface:   MGMT
Protocol:    Any
Source:      MGMT net
Destination: Any
```

## Firewall & Testing
* **Drop Everything from DMZ to LAN**
* **Drop Everything from DMZ to MGMT**

This is an example of what there rules should look like:
![firewall_rules]()




