# Activity 2.1 - Host Discovery

## Overview 🌍

* **Use ping to scan set ip range**
* **Use fping to scan set ip range**
* **Use nmap to scan set ip range**

## Using Ping to scan IPs

When pinging a specific range of IPs instead of the whole subnet, a for is used. This is a script used to scan ips `.2` - `.50`

```bash
for ip in $(seq 2 50); do
	ping -c 1 -W 1 10.0.5.$ip &>/dev/null && echo 10.0.5.$ip >> sweeper1.txt;
...
```
> [Full Script Here](https://github.com/devinziegler/Devin-Tech-Journal/blob/main/SEC-335/scripts/sweeper.sh)

### Script Explanation
* for loop saves number `2-50` in $ip. 
* For each number, ping with a count of 1 `-c 1`
* Wait max 1 second for response `-W 1`
* Ping the ip `10.0.5.$ip`
* Silence output (I do this because the output will be save in `sweeper1.txt`): `&>/dev/null`

## Using fPing to scan IPs

Fping allows the scanning of specific ranges so the for loop is not necessary in this case. This command scans .2-.50 and outputs only up IPs to sweeper2.txt

```bash
fping -a -g -q 10.0.5.2 10.0.5.50 >> sweeper.txt
```
> `-a flag` shows only ips that are up
> `-g flag` generates a target list, example: 10.0.5.2 10.0.5.50
> `-q flag` quiets output just shows ips (less verbose)

## Using nMap to scan Ips

Using nmap, we can do that same thing. This command will scan the same range and output to sweeper3.txt

```bash
nmap -n -sn 10.0.5.2-50 | grep "Namp scan report" | awk '{print $5}' > sweeper3.txt
```
> `-n` skips dns, only shows IP in output
> `-sn` Only pings, does not perform a port scan
