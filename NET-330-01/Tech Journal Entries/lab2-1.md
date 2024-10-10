# Cisco Packet Tracer Basics

 ## Assigning VLANS in switch CLI
```
vlan <vlan_number>
```
> This command will create the VLAN, and assign it to a number
```
name <VLAN_name>
```
> This is a subcommand for the vlan command, this allows you to name the vlan you just created. 

 ## Assinging VLANS to ports
 Once a vlan is created it can be assigned to a switch port. Navigate to the interface or use the `range` flag to select a range of interfaces. For Example:
```
int range fa0/1-5
```
> This command will allow you to configure ports fa0/1 through fa0/5

 ### Port Assignment
To assign a VLAN to a specific port in access mode, use the following command:
```
switchport access vlan <vlan_number>
```
 ### Assigning Trunk Ports:
Trunk ports allow vlan communication between switches.

```
switchport trunk encapsulation dot1q
```
> This command defines the encapsulation to be used on the trunking port.
```
switchport mode trunk
```
> This command will enable trunking on the selected interface

# Routing Between VLANS
Enable routing on a layer 3 switch with the following command:
```
ip routing
```
```
interface vlan <vlan#>
```
> Select the interface to configure

### Assign an IP to the VLAN interface
```
ip address <ip_address> <subnet_mask>
``` 
> Configures the VLAN interface with the desired IP address

