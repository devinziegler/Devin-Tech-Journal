
### Requirements
 * Router configured with two subnets 
 * Two client systems networked to the different subnets

## DHCP config
The DHCP server can be on any subnet, as long as the helper config is matching. Once the DHCP service is installed, it can be configured with the following example config

Add the following lines to `/etc/default/isc-dhcp-server`
```
INTERFACESv4="eth0"
```

Add the following config to `/etc/dhcp/dhcpd.conf`
```
subnet 192.168.1.0 netmask 255.255.255.0 {

range 192.168.1.200 192.168.1.205;

option routers 192.168.1.1;

}

subnet 192.168.3.0 netmask 255.255.255.0 {

range 192.168.3.200 192.168.3.205;

option routers 192.168.3.1;

}
```
> This can be put into the current file, or a new file in the config directory (the service is called isc-dhcp-server)

## Helper address config
For the two subnets to get a dynamic IP, a helper address needs to be setup. This is done on the router with the following:

```
ip helper-address
```
> Use the IP Address of the DHCP server in the IP helper config