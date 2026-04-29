# The Metasploit Framework

## Cupcake

Initial access was gained using `apache_mod_cgi_bash_env_exec`

![init](/SEC-335/images/Activity11.1/initial_foothold.png)

Root elevation was done through uploading an exploit to the system compiling, then running.

![root_flag](/SEC-335/images/Activity11.1/root_flag.png)

### Notes

* `python3 -c 'import pty; pty.spawn("/bin/bash")'` will make a better shell

* Type `exit` to return to meterpreter

## Nancurinir

Starting with an initial scan of nancurinir port 80 is open and accessible in a web browser:

![init_scan](/SEC-335/images/Activity11.1/init_scan.png)

> Using the website source code the password can be extracted (see previous week)

Nancurinir is hosting  phpmyadmin, testing the credentials in the login field they are confirmed to work

```yaml
username: gandalf
password: shallnotpass
```

### Using Metasploit

I searched metasploit for phpmyadmin and this was the result:

![exploit](/SEC-335/images/Activity11.1/exploit.png)

> Number 8 was chosen

First the options must be set for this exploit. Using information gathered from earlier & previous labs the following was filled in to match the server.

![options](/SEC-335/images/Activity11.1/options.png)

Finally the exploit can be run:

![running](/SEC-335/images/Activity11.1/shell.png)

Now that a shell is created, the web user can escelate to local user:

![user](/SEC-335/images/Activity11.1/su_gandalf.png)

> Password was gained from earlier lab

The user flag can be displayed:

![user_flag](/SEC-335/images/Activity11.1/user_flag.png)

Gandalf has root privilages so escolation is easy:

![elevate](/SEC-335/images/Activity11.1/gandalf_elevation.png)

The root flag can be displayedL

![root_flag](/SEC-335/images/Activity11.1/nancurunir_root_flag.png)
