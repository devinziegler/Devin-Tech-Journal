1. How to create pools
2. Working with **serverPool**
3. Assigning ip helper addresses
4. Any issues you encountered

## Setting Up DHCP

**Requirements**
1. Packet tracer server
2. Go To services and Select DHCP
3. Add pools for each VLAN in the network
4. Set Max users to that required of the VLAN
5. Make sure the service is enabled

## Helper Address Config
The helper address allows for 1 DHCP server on multiple subnets. Configure with the following:

1. Configure the following on the router connected to the DHCP server:
```
ip helper-address <address_of_dhcp_server>
```

## Testing
Once DHCP is configured, systems connected to subnets should be given IPs from their respective pools e.g.
```
Facstaff01: 10.34.1.15 
Facstaff02: 10.34.1.14

Lab1-01:    10.34.12.11
Lab1-02:    10.34.12.10
```
> Enable DHCP for client under settings