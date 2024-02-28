#secure-ssh.sh
#author devinziegler
#creates a new ssh user using $1 parameter
#adds a public key from the local repo or curled from the remote open
#removes roots ability to ssh in
echo "ALL YOUR CODE GOES HERE"

useradd -m -d /home/"$1" -s /bin/bash "$1"
sudo mkdir /home/"$1"/.ssh
cp /home/devin-loc/Devin-Tech-Journal/linux/public-keys/id_rsa.pub /home/"$1"/.ssh/authorized_keys
chmod 700 /home/"$1"/.ssh
chmod 600 /home/"$1"/.ssh/authorized_keys
chown -R "$1":"$1" /home/"$1"/.ssh

