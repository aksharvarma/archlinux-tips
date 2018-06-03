# Create the live USB
1. First download the iso.
2. Use `dd` to burn the iso onto a USB.
   `dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress oflag=sync`

You're done.

# Boot using the USB
Make sure you choose the USB as the boot medium

# Post-boot
Follow the instructions on https://wiki.archlinux.org/index.php/Installation_guide.

## Wireless
Pay attention to everything that is mentioned in the wiki. And if possible, understand what you are doing. That will save time when errors due to one thing don't confuse you into thinking that your driver is the problem.
[Wireless Network Configuration](https://wiki.archlinux.org/index.php/Wireless_network_configuration)
If you are using WPA/WPA2, you might want to refrain from doing `ip link set wlan0 up`. Probably because `wpa_supplicant` will later fail. Or at least that is what happened with me.

## Start dhcpcd
Might have to run `dhcpcd interfacename` to ensure that ping works. Do this if you can see that it is connected when using `iw dev interface link` but `ping` says that the network is unreachable.

## The rest
Go back to following instructions on the Installation guide as soon as you have internet connectivity.

Might want to add a few things to the installation list in here itself before trying to reboot. That saves setting up the network connections all over again.

* `base-devel` group
* `iw`, `wpa_supplicant` (to get the network to install the rest of the packages)
* 

## General recommendations
[Link](https://wiki.archlinux.org/index.php/General_recommendations)

### User creation
Create your own user, add to the following groups: `sys, lp, network`
    `gpasswd -a USERNAME group_name`
Make sure to create a folder for the user, and to make sure that the owner for that is the user, and not root.

### Add to sudoers
Add the line: `username ALL=(ALL) ALL` to the `User privilege specification` after the line for `root`.

### ssh-add
If you are going to copy your ssh config from an old machine, then you need to add the private keys to the ssh-agent. For example:
`eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
sh-add ~/.ssh/github_rsa
ssh-add ~/.ssh/mozilla_rsa`

This [website](https://gist.github.com/grenade/6318301) also lists the correct kind of permissions that should be present for the ssh files: 
Basically all the private keys should be 600, all public keys (and `authorized_keys`, `known_hosts`, `config`) should be 644. The `.ssh` folder should be 700.

### git config
Might have to add your username and email to your git configuration again.
