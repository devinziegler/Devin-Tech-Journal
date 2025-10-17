# Milestone 2

## Overview 🌎

* **Setup Windows Server for `sysprep`**
* **Download and install AD on new windows VM**

## Current Network Diagram
![Network Diagram](working_diagram1.png)
> Diagram made in plantuml [here](network.plantuml)

## Configuring Windows Server for Sysprep
1. Type `sconfig` in powershell
2. Use option 6 to download and install updates ultill there are none left
3. Make sure to set time zone & configure updates with what the system requires
4. Install VMware Tools through the actions menu in ESXi

## Sysconfig
 * Open Powershell ISE (Make sure it is x64 NOT x86)
 * Paste the following script & hit run [script](https://raw.githubusercontent.com/gmcyber/480share/master/ssh-prep.ps1)

 ## Promote System To DC
  * A refresher on AD and Domain Controllers can be found [here](https://github.com/devinziegler/Devin-Tech-Journal/wiki/Lab-02-%7C-DNS---ADDS-Role)

  * Users can be created & added to groups in the `Active Directoty Users and Computers` application.
  * Configure DNS with the following in `DNS Manager`:
  1. Add a reverse lookup zone
  2. Add a host to <name>.local, make sure to add an associated PTR record

  # VCenter Installation

 **Mount the VCenter ISO to the mgmt system using the following Steps**
 1. Switch the file system to the ISO in the datastore
 2. Mount the ISO witht the following:
 ```bash
sudo mkdir /mnt/iso
sudo mounmt /dev/cdrom /mnt/iso
 ```
 3. Navigate through the ISO untill your reach the installation script
 * Complete the install filling out the prompts. Walkthrough video can be found [here](https://drive.google.com/file/d/1IjURvaxPwUdoBzInhBUXNPHzI1FZfX9q/view)
 > This process will take a long time!! :)

 ## Notes and Tips
  **Make sure each system is synced with `pool.ntp.org`**
  
  Check NTP server on windows with:
  ```ps1
w32tm /query /source
  ```

