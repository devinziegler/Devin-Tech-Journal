# Lab 9.1 Overview

* Accessing the target

## Using Nmap to locate the host

Because the only thing known about the host is the domain name the IP can be found using nmap:

```bash
nmap -sn --dns-servers 10.0.5.22 10.0.5.1-100
```

![dns](/SEC-335/images/Week9/dns.png)

> The target IP is 10.0.5.31

## Inital Port Scan of Target

Using nmap the target can be scanned for ports and services of interest:

```bash
nmap -sV -A 10.0.5.31
```

![scan](/SEC-335/images/Week9/initial.scan.png)

From this scan we can see:

* Port 22 (ssh) is open
* Port 443 (https) is open
* Port 3389 (rdp) is open

This means that the system is most likely windows hosting some sort of web service.

## Public access

When using the url `https://10.0.5.31` we can see there is a service being hosted, and php is being used:

![php](/SEC-335/images/Week9/php.png)

There is also a field that can be filled out by the user:

![field](/SEC-335/images/Week9/field.png)

Seeing this text entry field, my first thought is to see if the service is exploitable by sql the following was passed into the text field:

```sql
123' OR '1'='1
```

This worked and we now have user access as `john smith`

![login](/SEC-335/images/Week9/login.png)

Unfortunatly it looks like this site doesnt function very well perhaps a look at the source code will receal more information.

![source](/SEC-335/images/Week9/source.png)

> Even though the button is disabled, the url is shown in the source code

Following the url we are now able to access and take the exam for `John D Smith`

![exam](/SEC-335/images/Week9/exam.png)

## Gaining user access

I decided to shift my efforts to finding out more about the website structure. By using `dirb` I was able to find the admin login page.

```bash
dirb https://10.0.5.31/entrance_exam/ -o gloin.dirb.txt
```

Running grep against the output list looking for ok requests provided me with the admin url:

![dirb](/SEC-335/images/Week9/dirb.png)

Lets see if this login field is also vulnerable to sql injection like the user field

```sql
admin' OR '1'='1
```
> This worked we now have access to the admin panel (password doesnt matter can be anything)

![admin](/SEC-335/images/Week9/admin.png)

## Metasploit

At this point, I couldn't find anything else to exploit so I decided to take a different route. Using searchsploit I found an exploit for `Online Entrance Exam System`.

```bash
searchsploit online entrance exam system
```

![metasploit](/SEC-335/images/Week9/metasploit.png)

Using this exploit I managed to find the hash shown below:

![adminhash](/SEC-335/images/Week9/adminhash.png)

The full exploit URL is shown below:

```http
https://10.0.5.31/entrance_exam/take_exam.php?id=%27+UNION+SELECT+1,username||%27;%27||password,3,4,5,6,7+FROM+admin_list;
```

## Cracking the hash

This seems to be a md5 hash. I will save the hash to a file and crack it using hashcat and rockyou.

![cracked](/SEC-335/images/Week9/cracked.png)

## Admin Flag

Using this password I was able to get administrator access to Golin

![rootflag](/SEC-335/images/Week9/rootflag.png)

## User Flag

To get user access, all we have to do is change gloins password ssh into the account:

![user](/SEC-335/images/Week9/user.png)

> In this case I just changed it to the admin password

Now we can log into the user account `gloin`:

![userflag](/SEC-335/images/Week9/userflag.png)

## Mitigation

1. The service being hosted is extremely vulnerable to injection. Perhaps this can be fixed using user input checks to make sure people can't send sql command through text boxes. Not to mention I was able to get the admin password hash through injection in the url.

2. The actual service is insecure and I was able to traverse through the pages even when they were "disabled".

## Reflection

This assignment went well for the most part, The part that cost me the most time was navigating around the website instead of just looking up exploits. Other than that once I used the exploit, I was able to quickly access the admin & user accounts. 