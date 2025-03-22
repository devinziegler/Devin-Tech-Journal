# VyOS Setup Guide

This guide breaks down the configuration into manageable sections for setting up your VyOS system.

---

## 1. Hostname & Basic System Settings

```vyos
set system host-name 'fw01-devin'
set system config-management commit-revisions '100'
set system name-server '10.0.17.2'
set system ntp server time1.vyos.net
set system ntp server time2.vyos.net
set system ntp server time3.vyos.net
set system syslog global facility all level 'info'
set system syslog global facility protocols level 'debug'
set system conntrack modules ftp
set system conntrack modules h323
set system conntrack modules nfs
set system conntrack modules pptp
set system conntrack modules sip
set system conntrack modules sqlnet
set system conntrack modules tftp
```

---

## 2. User Account Configuration

```vyos
set system login user vyos authentication encrypted-password '<encrypted-password>'
```

---

## 3. Console Configuration

```vyos
set system console device ttyS0 speed '115200'
```

---

## 4. Network Interfaces

```vyos
set interfaces ethernet eth0 address '10.0.17.147/24'
set interfaces ethernet eth0 description 'SEC350-WAN'
set interfaces ethernet eth0 hw-id '00:50:56:a1:75:3d'

set interfaces ethernet eth1 address '172.16.50.2/29'
set interfaces ethernet eth1 description 'SEC350-DMZ'
set interfaces ethernet eth1 hw-id '00:50:56:a1:10:56'

set interfaces ethernet eth2 address '172.16.150.2/24'
set interfaces ethernet eth2 description 'SEC350-LAN'
set interfaces ethernet eth2 hw-id '00:50:56:a1:ce:d5'

set interfaces loopback lo
```

---

## 5. DNS Forwarding

```vyos
set service dns forwarding allow-from '172.16.50.0/29'
set service dns forwarding allow-from '172.16.150.0/24'
set service dns forwarding listen-address '172.16.50.2'
set service dns forwarding listen-address '172.16.150.2'
set service dns forwarding system
```

---

## 6. SSH Service

```vyos
set service ssh listen-address '0.0.0.0'
```

---

## 7. Routing

```vyos
set protocols static route 0.0.0.0/0 next-hop 10.0.17.2
set protocols rip interface eth2
set protocols rip network '172.16.50.0/29'
```

---

## 8. NAT Rules

### Destination NAT (Port Forwarding)

```vyos
set nat destination rule 10 description 'HTTP->WEB01'
set nat destination rule 10 destination port '80'
set nat destination rule 10 inbound-interface 'eth0'
set nat destination rule 10 protocol 'tcp'
set nat destination rule 10 translation address '172.16.50.3'
set nat destination rule 10 translation port '80'

set nat destination rule 50 description 'Forward SSH'
set nat destination rule 50 destination port '22'
set nat destination rule 50 inbound-interface 'eth0'
set nat destination rule 50 protocol 'tcp'
set nat destination rule 50 translation address '172.16.50.4'
set nat destination rule 50 translation port '22'
```

### Source NAT (Masquerade)

```vyos
set nat source rule 10 description 'NAT FROM DMZ to WAN'
set nat source rule 10 outbound-interface 'eth0'
set nat source rule 10 source address '172.16.50.0/29'
set nat source rule 10 translation address 'masquerade'

set nat source rule 11 description 'NAT from LAN to WAN'
set nat source rule 11 outbound-interface 'eth0'
set nat source rule 11 source address '172.16.150.0/24'
set nat source rule 11 translation address 'masquerade'

set nat source rule 30 description 'NAT FROM MGMT to WAN'
set nat source rule 30 outbound-interface 'eth0'
set nat source rule 30 source address '172.16.200.0/28'
set nat source rule 30 translation address 'masquerade'
```

---

## 9. Firewall Rules

### DMZ-to-LAN

```vyos
set firewall name DMZ-to-LAN default-action 'drop'
set firewall name DMZ-to-LAN enable-default-log
# Add rules 10, 11, 20
```

### DMZ-to-WAN

```vyos
set firewall name DMZ-to-WAN default-action 'drop'
set firewall name DMZ-to-WAN enable-default-log
# Add rules 1 and 999
```

### LAN-to-DMZ

```vyos
set firewall name LAN-to-DMZ default-action 'drop'
set firewall name LAN-to-DMZ enable-default-log
# Add rules 1 and 2
```

### LAN-to-WAN

```vyos
set firewall name LAN-to-WAN default-action 'drop'
set firewall name LAN-to-WAN enable-default-log
# Add rule 1
```

### WAN-to-DMZ

```vyos
set firewall name WAN-to-DMZ default-action 'drop'
set firewall name WAN-to-DMZ enable-default-log
# Add rules 1, 10, 20
```

### WAN-to-LAN

```vyos
set firewall name WAN-to-LAN default-action 'drop'
set firewall name WAN-to-LAN enable-default-log
# Add rule 1
```

---

## 10. Zone-Based Firewall Policy

```vyos
set zone-policy zone DMZ interface 'eth1'
set zone-policy zone LAN interface 'eth2'
set zone-policy zone WAN interface 'eth0'

set zone-policy zone DMZ from LAN firewall name 'LAN-to-DMZ'
set zone-policy zone DMZ from WAN firewall name 'WAN-to-DMZ'

set zone-policy zone LAN from DMZ firewall name 'DMZ-to-LAN'
set zone-policy zone LAN from WAN firewall name 'WAN-to-LAN'

set zone-policy zone WAN from DMZ firewall name 'DMZ-to-WAN'
set zone-policy zone WAN from LAN firewall name 'LAN-to-WAN'
```
