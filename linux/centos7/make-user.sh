#!/bin/bash
# This script takes three parametes that shoud be in this order - Username Password Hostname
# This script creates a user and adds them to the wheel group
# This script sets the hostname using 
useradd "$1"
passwd "$1" "$2"
usermod -aG wheel "$1"

hostnamectl set-hostname "$3"

