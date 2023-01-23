#! /bin/bash
# ssh-copy-id can be used to install a user's SSH key for
# the pi user. After any new SSH keys are installed,
# those keys need to be propagated to the flight and git
# accounts. This script will do that when run under sudo:
#    sudo ./install_ssh_keys.sh
cat /home/pi/.ssh/authorized_keys >/home/flight/.ssh/authorized_keys
cat /home/pi/.ssh/authorized_keys >/srv/git/.ssh/authorized_keys
