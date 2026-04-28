# Linux Permission Vulnerabilities

## Suid Programs 

Here is a one liner that can locate `suid` programs accross a system.

```bash
find / -perm -4000 -type f 2>/dev/null
```

### Suid Breakdown

* The `find` command is given / as the root directory

* `-perm -4000` finds thiles with suid set to 4000

* `-type f` denotes only refular files

* `2>/dev/null` takes permission denied errors and throws them out

## Root owner world writable files

These files can be dangerous and used for privilage escolation. Here is a script to locate them accross the system:

```bash
find / -path /proc -prune -o -user root -perm -o+w -type f -print 2>/dev/null
```

### Word Writable Breakdown

* `find /` start find at root 

* `-path /proc -prune` doesnt scan the /proc directory

> /proc gives a lot of false positives

* `-user root` - File is owned by root

* `-perm -o+w` - Others have write (word writable)

* `-type f` - regular file

> rest is the same os previous command `-print` is needed with prune command.