# archlinux-tips
Contains basic tips and how tos for various Arch Linux related tasks. The focus will be on things that are useful to me, but will be presented in a manner that may be useful for others as well.

# Files
These files are currently present in the repo.

## Installation Guide
A simple step-by-step guide for installing Arch from an existing linux. Although it borrows heavily from Arch Wiki, it also tries to explain what is happening at each step as well as the motivation for the various steps.

## `my-arch-chroot.sh`
A simple shell script that combines commands needed to go into a arch chroot environment while sitting inside another Linux.

## `proxy-enable.sh`
A shell script that exports proxy environment variables in case a proxy is needed to access the network.

## `installable-package-list.txt`
A list of packages that I use/used/know about, divided into sections along with a short description of what each package does. Users can use this in conjugation with the `arch-pacman-install-helper.sh` script to ease the package installation process.

## `arch-pacman-install-helper.sh`
A simple short script that uses the list of packages in `installable-package-list.txt` (or somewhere else) to install them into the system based on the users needs. 

## `openbox-configuration.md`
Details of the particular configurations used along with the Openbox window manager.

## `power-management-tlp.md`
Details of the configurations used for `tlp` to manage power consumption so as to improve battery life on laptops.

## `setlayout.c`
A small C program that is used to control the structure/layout of the workspaces/desktops in the openbox window manager.

