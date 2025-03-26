# Checklist

1. ssh keys shared
2. ansible is installed on mgmt01
3. Edit Host file to match current environment
4. Run the following command

```
ansible-playbook -i hosts nginx_playbook.yaml --ask-become-pass
```
