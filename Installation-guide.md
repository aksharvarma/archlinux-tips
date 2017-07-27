# Introduction

The following guide explains how to install Arch Linux onto one of your disk's partitions, sitting inside Ubuntu (or another Linux OS). This guide borrows heavily from ["Installing from existing Linux - Arch Wiki"](https://wiki.archlinux.org/index.php/Install_from_existing_Linux) and the [Installation guide of Arch wiki](https://wiki.archlinux.org/index.php/Installation_guide) among others. This guide additionally tries to explain what is happening at each stage and the motivation for doing various things the way they have been done. At times, this gets slightly sidetracked explaining aspects of Arch's functioning, which in the author's opinion is particularly useful for new Arch users.

* We'll be installing Arch Linux starting from an existing Linux OS. The particular instructions used here work for Ubuntu, and since they are the longer set of commands, they should also work in other OSes. However, I have not tested them using any other OS.
* The assumption is that you have at least 3 partitions of your disk. One which has the Ubuntu OS; this gets mounted as / for Ubuntu. Another which houses your home folder which gets mounted as /home/USERNAME in al Linux OSes. The third partition would be where you would install the Arch OS.
  Let these be:
  1. /dev/sda1  (Housing Ubuntu's / folder)
  2. /dev/sda2  (Housing Arch's / folder)
  3. /dev/sda3  (Housing the home folder to be mounted at /home/USERNAME)
  
  _Note: One can use these broad instructions without this structure. However, having this structure allows one to use multiple OSes with the same home folder and that, in turn allows us to carry over our files from one OS to another without any extra effort. This means that if your OS goes bust, you can still finish your urgen work on your backup OS without being afraid of losing your data. Even if you don't keep your home folder separate, you would still need two partitions to install Arch and Ubuntu both. And you would need to provide enough space in both to accommodate their individual home folders._
  
# Outline
* Get the Arch iso, untar it, chroot into it.
* Install basic packages inside the chroot environment.
* Install these basic packages onto the actual partitions to be used.
* Configure basic aspects and update Ubuntu's grub to make it locate Arch; then reboot and test if you can reach the _console_ of Arch.
* Back in Ubuntu, start installing packages needed to get graphics in Arch and configure it to make it usable; then reboot and test if you can reach the graphical interface.
* Install remaining packages according to need. (Can be done in Ubuntu while doing other work)
* Switch over to Arch's grub.


## Setting up the ISO to get started
We would be downloading the basic archlinux-bootstrap image and installation starts with things available there.

* Make a folder where the bootstrap tarball would be untarred, say `~/Archlinux` and `cd` into that folder.
* Downloaded `archlinux-bootstrap-20yy.mm.dd-x86_64.tar.gz` (about 100MB) from [the latest iso folder](https://mirrors.kernel.org/archlinux/iso/latest/). The `yy.mm.dd` part is the year, month and date when the tarball was created. Make sure to get the bootstrap version.
* Untar the tarball there using `tar zxvf`, it should create a root.x86_64 foler automatically.

These steps can be done using the following series of commands run inside a terminal in Ubuntu:

	mkdir -p ~/Archlinux && cd ~/Archlinux
	# Make sure to replace yy.mm.dd with the correct values!
	curl -U https://mirrors.kernel.org/archlinux/iso/latest/archlinux-bootstrap-20yy.mm.dd-x86_64.tar.gz
	tar xzf https://mirrors.kernel.org/archlinux/iso/latest/archlinux-bootstrap-20yy.mm.dd-x86_64.tar.gz 
	cd root.x86_64

We now need to chroot into this place to allow us to use the Arch bootstrap as if it were an OS (use some commands to download the rest of the required material and get it installed). These commands have been put into a small shell script (`my-arch-chroot.sh`) as they will be needed multiple times later on.**\*** You can put the script in your `~/bin` and `chmod +x` on it to make it executable

	cp /etc/resolv.conf etc
	mount -t proc /proc proc
	mount --rbind /sys sys
	mount --rbind /dev dev
	mount --rbind /run run    # (assuming /run exists on the system)
	chroot . /bin/bash

**\*** _Note: When you run the `my-arch-chroot.sh` scrip the first time, you will need to comment out the first four lines. For subsequent runs, those lines should **not** be commented._

## Installing `base` and `base-devel`
The bootstrap image is really barebones, it doesn't even have basic editors. So we need to install the basic packages from the `base` and `base-devel` package groups. We need to get Arch linux's _pac_kage _man_ager `pacman` setup so that it can download and install packages.

### Pacman initialization
We follow the instructions from the [Using the chroot environment](https://wiki.archlinux.org/index.php/Install_from_existing_Linux#Using_the_chroot_environment) section to initialize `pacman` for downloading packages.

	pacman-key --init   # type lots of random keys in some other application to generate entropy
	pacman-key --populate archlinux

_Note: You may need to install `haveged` on the host system (Ubuntu) before running the previous two commands. Otherwise systemd will recognize that we are trying to swindle it inside a chroot environment. Further details and links can be found in the Arch Wiki section._

### Selecting mirrors to download packages from
Now you need to tell pacman where it should look in order to find packages. This is done by enabling some servers as mirrors in `/etc/pacman.d/mirrorlist`. You can refer to [Enabling specific mirrors](https://wiki.archlinux.org/index.php/Mirrors#Enabling_a_specific_mirror) for more details.

You would essentially need to uncomment lines from `/etc/pacman.d/mirrorlist` to enable those servers as mirrors. We do something slightly different, as mentioned [here](https://wiki.archlinux.org/index.php/Arch_Linux_Archive#How_to_restore_all_packages_to_a_specific_date). We freeze pacman's mirrors to use repositories as they were on a specific date.

This particular mechanism means that we are always see packages from a particular date _until we are ready_ to update our system. This makes the system slightly more stable. It also means that you would never have to upgrade the whole system just to install a new package (if we don't do this, some dependency may be using an old version which we would have to update in order to install the new package). When we are ready to upgrade, we simply change the date that we are using and proceed with a full system upgrade. We get the benefits of the rolling system that arch uses, while still keeping our configuration quite stable.

#### (Optional) Set up proxies if required.
In case your network needs proxies to access the internet, you should enable them in the chroot environment as well. The following commands can be put into a file, say `proxy_enable.sh` sitting inside `/etc/profile.d/`. Later, in case you want to disable proxies or change them, all you need to do is to interchange the commenting between the first and second lines. To get changes implemented, you would have to source the file after making the changes: `source /etc/profile.d/proxy_enable.sh`

	export http_proxy=http://192.168.32.1:8080/
	# export http_proxy=''
	export https_proxy=$http_proxy
	export ftp_proxy=$http_proxy
	export rsync_proxy=$http_proxy
	export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

### Install `base` and `base-devel` via pacman (bootstrap level)
We force pacman to refresh it's package lists by using `pacman -Syy` ([pacman forced refresh of package lists](https://wiki.archlinux.org/index.php/Mirrors#Force_pacman_to_refresh_the_package_lists)) before we tell it to install packages. While this can be done simultaneously, separating helps in diagnosing errors.

_Note: It would be a nice idea to uncomment repositories from `/etc/pacman.conf` before refreshing package lists. Particularly, the `core`, `extra`, `community`, `multilib` and `archlinux-fr` repositories are good to have access to. It would also be a nice idea to keep commented any repositories with `testing` in their name._

With that done we proceed with installation using the following command:
`pacman -S --needed base base-devel`
Users who have not partitioned their systems yet should also consider installing `parted` although using Ubuntu's `gparted` would be an easier option.

## Installing basic packages onto the Arch partition
Till now we have installed packages into a chroot environment, which is still sitting inside the partition of Ubuntu. We actually want them installed in the Arch partition. All we did till now is get the necessary packages to do that job. We would continue using the chroot environment and the packages we installed in those folders to accomplish our task.

### Get the Arch (and home) partitions mounted
Sitting inside the chroot you now run the `my-arch-chroot.sh` script _after uncommenting the first four lines_ so that the correct partitions get mounted at the correct places. The commands have been replicated here.

	sudo mkdir -p /mnt/Arch  # Do only once. Create mount point for Arch root partition
	sudo mount /dev/sda1 /mnt/Arch # mount arch root partition
	sudo mount /dev/sda3 /mnt/Arch/home # mount home partition
	cd /mnt/Arch
	sudo cp /etc/resolv.conf etc
	sudo mount -t proc /proc proc
	sudo mount --rbind /sys sys
	sudo mount --rbind /dev dev
	sudo mount --rbind /run run    # (assuming /run exists on the system)
	sudo chroot . /bin/bash


### Install `base` and `base-devel` onto the partition
Now, we have the `base` and `base-devel` groups with us, albeit in the original bootstrap level chroot environment. We use these, to install the `base` and `base-devel` groups into the Arch partition.

	pacstrap -i /mnt base base-devel

Technically arch has been installed at this stage, and you are still inside Ubuntu, doing your work on the side.

## Configure basic aspects, `update-grub`, reboot and test.
I said _technically Arch has been installed_ because while the packages are there and the kernel has been setup, we can't immediately start using it without a few configuring a few basic things.

_Note: We only discuss things that we needed, further configuration can be done by reading through the [configure the system](https://wiki.archlinux.org/index.php/Installation_guide#Configure_the_system) section of the Installation Guide of Arch._
 
#### `fstab`
We set the fstab using the following command. The fstab (probably short for filesystem table) is what determines which disk partitions and other block devices are mounted onto the filesystem. This is what will make the arch partition to mount as root and our home partition to mount as our home partition.
	
	genfstab -U /mnt > /mnt/etc/fstab

#### Change root
You now change the root into the new system by typing the following command. Note that here `arch-chroot` is a command of Arch Linux and not the script that we had made for ease.

	arch-chroot /mnt /bin/bash

Doing this changes the apparent root directory from the `root.x86_64` to the one of the Arch partition. The upcoming commands' effect will be reflected there.

#### Locales
From: [Localization - Arch Wiki](https://wiki.archlinux.org/index.php/Locale)
	_Locales are used by glibc and other locale-aware programs or libraries for rendering text, correctly displaying regional monetary values, time and date formats, alphabetic idiosyncrasies, and other locale-specific standards._

We do some basic things here.
	
	nano /etc/locale.gen 
	# Uncomment en_US.UTF-8 UTF-8. Also en_GB and en_IN (or others based on requirement)
	nano /etc/locale.conf 
	# Insert line: LANG=en_US.UTF-8
	ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
	# You can set to your time zone by replacing Asia/Kolkata with Region/City 
	locale-gen #generate the locales

#### Root password
We need to set a root password. We are already using the system as root, hence simply typing `passwd` will bring you to a prompt allowing you to set your root password. This is not the password for _your account_. Another thing to note is that unlike other linux distros, arch actually allows you to login using the root account. So you should keep something you'll remember so that you can login as root and repair any damages you may do later.

#### Add user and password
While Arch may allow logging in as the root account, you can also add your own user right now to test that as well.

	useradd -d /home/FULL-PATH-TO-HOME -u 1000 USERNAME
	passwd USERNAME
	# in my case FULL-PATH-TO-NAME AND USERNAME are both simply akshar
	# the -u 1000 uses a number taken from /etc/passwd of Ubuntu. This allows simply mapping the home of Ubuntu as the home of Arch.
	
#### Exiting to Ubuntu terminal
At this moment, we are sitting inside the `arch-chroot`, which is inside a chroot environment made by `my-arch-chroot.sh` which is once again inside the first `my-arch-chroot.sh`. (Inception yet?)

To exit from all this and get to the Ubuntu terminal, we need to call the `exit` command **thrice**.

#### `update-grub` from Ubuntu
Once out of all the chroot environments and in the Ubuntu terminal we can run `sudo update-grub` to see if `grub`**\*** recognizes the Arch partition or not. It should automatically detect the partition and add it to the boot menu.

**\*** You will need to install `grub2` and perform `grub-install` in Ubuntu if you don't have your grub already setup.

#### Reboot and test
Now we are ready to get into Arch for the first time. Reboot from Ubuntu, and choose Arch from the boot menu of grub. 

This should boot you into a `tty` like console terminal which should allow you to login into root and your account as well. You can test if your home folder is visible and so on using `ls ~/` and perform other basic checks.

## Get graphics working, install major packages and configure to make comfortable.
We have already gotten Arch installed. However, there's a lot to be done to take it to the level of comfort Ubuntu users are used to. The first step is to get graphical interfaces setup.

From now on, the steps are comparatively much simpler. To get started, we just run `my-arch-chroot.sh` to enter a chroot environment with the right partitions to _get into the Arch OS_ from within Ubuntu. After setting any proxy settings as required, we can start installing the required packages and making any other configuration that is needed.

Before we get started with things inside the chroot environment, copy the hostnames used in Ubuntu sitting inside an Ubuntu terminal (but this should be done only after mounting Arch (which the `my-arch-chroot.sh` command does)). Run the following commands while sitting in Ubuntu:

	sudo cp /etc/hosts /mnt/Arch/etc/hosts
	sudo cp /etc/hostname /mnt/Arch/etc/hostname	

#### `X`, display managers, window managers, etc.
* Install X11: `pacman -S xorg-server xorg-apps`
`xorg-server` is the one that provides the X11 thing. `xorg-apps` is a group consisting of some applications that go along with this and are useful.

* Install a display/login manager: `pacman -S --needed lightdm lightdm-gtk-greeter`. We use the lightdm manager for now. 
  
  You'll need to enable the systemd service for this using: `systemctl enable lightdm.service`.

* Install a window manager: `pacman -S --needed openbox`. We use the openbox window manager for now.

* Install a system tray package so that applets can display: `pacman -S --needed tint2`. Note that the choice or even the need of something like this would change depending on your choice of display and window managers.

If you choose a desktop environment (why would you in Arch?) you would not need to install any of the previous three things. Your desktop environment would do the job for you.

#### Mouse, graphics/video, terminal emulator
* Install mouse touchpad related package: `pacman -Sy --needed xf86-input-synaptics`

* Install some video/graphics related packages: `pacman -S xf86-video-intel mesa-libgl`

* Install a terminal emulator: `pacman -S terminator`. We prefer the `terminator` package but you can choose others like `xterm`.

#### Networking packages, including Wifi
* Packages for using WPA, including a gui application: `pacman -Sy wpa_supplicant wpa_supplicant_gui`. It might be possible to complete your networking related requirements using only this, however since that hasn't been tested fully, we also list packages that provide easy to use and familiar interfaces.

  Similar to the display manager, we need to enable this: `sudo systemctl enable wpa_supplicant.service`


* Network manager and applet: `pacman -Sy networkmanager network-manager-applet`.

  We need to enable this as well: `sudo systemctl enable NetworkManager.service`
   <!-- # pacman -Sy iw -->

We also add ourselves to the network administrators group: `sudo gpasswd -a USERNAME network`

#### Misc
* Some additional packages that provide notification related, icon-theme and keyring related functionalities: `pacman -Sy xfce4-notifyd hicolor-icon-theme gnome-keyring`. These are useful things to have and while they may not be mandatory (except perhaps the keyring), they are still useful enough to install. <!-- [Note to self: Reconsider their need.] -->

### Reboot and test
At this point we are ready to test out whether the graphical aspects as well as the networking aspects work or not. It is advisable to test right now instead of waiting for installation of other applicaitons so that any errors can be addressed right away and installation work doesn't have to be repeated.

## Install remaining packages.
Assuming that things work out, we can now proceed to install all the packages that we want.

The details of this are in the script: `arch-pacman-install-helper.sh`. The script contains all the details of the packages that are being installed, categorized according to usage or type. The same is not being replicated here as the comments in the script suffice.

## Switching over to Arch's grub.

After everything is working, and you are ready to completely shift to Arch you can switch over control of the boot menu to a grub in Arch:

	sudo pacman -Sy --needed grub os-prober
	#grub provides grub related tools and os-prober probes partitions for OSes.
	sudo grub-install --recheck /dev/sda    # Switch control to Arch's grub by installing it into the MBR.
	sudo grub-mkconfig -o /boot/grub/grub.cfg   #Make the boot menu using detected OSes. os-prober should detect Ubuntu and create a boot menu entry for it automatically.


## Conclusion
That should have you settled with your Arch and with Arch as your main OS. The majority of this can be done while sitting inside Ubuntu itself so that you can continue with your other work while you are setting up your Arch and waiting for packages to download.

Of course, this is simply the starting and there are numerous other things that need to be customized, after all customization and the bottom up approach is one of Arch's strengths.
