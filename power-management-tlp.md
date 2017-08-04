## Power Management using TLP

This file describes how some basic power management can be done using `tlp` so as to improve battery performance. The need for this is that linux systems are designed so that they work everywhere and hence may not be particularly suited for your system by default. At least that is the very high level idea. Using tools like `tlp` allows us to control low level features that affect the power consumption on your machine. 

What is described below is merely what worked for the author, and may not work for you. Standard warning about doing something without knowing what it is applies all the more in case of power management. You have been warned.

### Handling conflicting services, packages, etc.
After you install `tlp` (do it now if you haven't and yet want to continue on this quest), you will need to ensure that other services don't interfere with the functioning of `tlp`. You should definitely not have more than one power management tool installed unless you really know what you are doing. Further, there are a few services that should be masked, enabled, disabled, etc. so that they don't interfere with `tlp`.

The `rfkill` service and socket should both be masked so that they are never interfere with `tlp`.

	#Mask systemd things that will interfere
	sudo systemctl mask systemd-rfkill.service
	sudo systemctl mask systemd-rfkill.socket

The following note has been copied straight out of the [TLP Arch Wiki page](https://wiki.archlinux.org/index.php/TLP):

> Note: `tlp.service` starts `NetworkManager.service` if it is available: [FS#43733](https://bugs.archlinux.org/task/43733). If you use a different [network manager](https://wiki.archlinux.org/index.php/List_of_applications#Network_managers), [edit](https://wiki.archlinux.org/index.php/Edit) `tlp.service` in order to remove the service (line `Wants=`) or [mask](https://wiki.archlinux.org/index.php/Mask) it.

### Enable service
Now the `tlp` services should be enabled:

	sudo systemctl enable tlp.service
	sudo systemctl enable tlp-sleep.service

These won't have any effect without system restart. You should do `tlp start` (with sudo) to immediately start `tlp`. This command is also useful to make any changes to settings effective.

### Diagnostics
You can see the effect of `tlp` by running `tlp-stat`. This may provide certain suggested packages to be installed. You should consider installing them. For me, `ethtool` and `smartmontools` were suggested at the end of `tlp-stat` output. I also installed `x86_energy_perf_policy` because it controls the CPU performance vs energy savings policy.

	sudo pacman -S --needed ethtool smartmontools x86_energy_perf_policy

### Changes made to default `tlp` settings
* Uncomment the min/max P-state for Intel Core processors. Values are stated as a percentage (0..100%) of the total available processor performance.
	
		CPU_MIN_PERF_ON_AC=0
		CPU_MAX_PERF_ON_AC=100
		CPU_MIN_PERF_ON_BAT=0
		CPU_MAX_PERF_ON_BAT=30

* Set the Optical drive to be powered off when on battery. (This is the CD drive, AFAIK. Nothing lost here. Can be restarted by ejecting.)

		BAY_POWEROFF_ON_BAT=1


### Misc
Use the following command to check how much Watts of power you draw in. Single digit is good, close to 5 is better.
	
	awk '{print $1*10^-6 " W"}' /sys/class/power_supply/BAT0/power_now

The `/sys/class/power_supply/BAT0` has lots of information about the battery status. Your battery _may_ have a name other than `BAT0` but otherwise, this is the folder you need to look into to see statistics about your battery. Further, you may need to perform unit conversions similar to what the above `awk` command does.
