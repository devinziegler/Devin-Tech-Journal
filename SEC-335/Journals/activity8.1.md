# Class activity 8.1 Notes

## Weevely

`Weevely` is a tool that can generate a php backdoor and connect back to it.
This backdoor is more stealthy than a tradition web shell because it is
encrypted and will not show plain text over the network. Normal webshells
are unencrypted and can be viewed by anyone using wireshark. Generating a
backdoor using weevely can be done with the following command

```bash
weevely generate <username> <path_to_file.php>
```

> This generates the backdoor file that will be uploaded to the target via ftp

Using the backdoor

```bash
weevely <url_to_exploit> <password>
```

> The url is the path on the target to the webshell that was uploaded, password
was defined earlier.

## Reflection and Notes

Weevely has a slight problem on new versions of Kali. When first using the
program I was encountering many python errors. This problem was solved by
following the steps in this article by medium: [Fixing Weevely](https://medium.com/@hackmyth24/fixing-weevely-on-kali-linux-python-3-13-complete-guide-d3c76ddd476d)
