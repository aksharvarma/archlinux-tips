## Openbox configuration
Openbox is the window manager that is closest to the one that distros like Ubuntu provide. There is a bit of configuration that will need to be done to get it working (the same holds for most window managers). It is advisable to have `oblogout`, `obkey` and `obmenu-generator` (or some other menu generator) for first time users; some of these are AUR packages.

In case you select some other window manager, you'll need to configure it yourself.

### Oblogout config
Set things up for system shutdown like events (`oblogout` needs to be installed): `sudo nano /etc/oblogout.conf`

	#######################################################
	[settings]
	usehal = false

	[looks]
	opacity = 70
	bgcolor = black
	buttontheme = oxygen
	buttons = cancel, restart, shutdown, suspend, lock
	# You can add other buttons as per your wish

	[shortcuts]
	# Set shortcuts as your taste. These are key shortcuts when the menu comes. You can also comment out some of these.
	cancel = Escape
	shutdown = S
	restart = R
	suspend = U
	#logout = L
	lock = L
	#hibernate = H

	[commands]
	# You can choose which to allow and which not.
	shutdown = systemctl poweroff
	restart = systemctl reboot
	suspend = systemctl suspend
	#hibernate = systemctl hibernate
	#logout = openbox --exit
	lock = slock
	#switchuser = gdm-control --switch-user
	#safesuspend = safesuspend
	#######################################################

### Menu config
If you have `obmenu-generator` installed then replace entire `~/.config/openbox/menu.xml` with following lines:

	################
	<?xml version="1.0" encoding="utf-8"?>
	<openbox_menu>
		<menu id="root-menu" label="OpenBox 3" execute="/usr/bin/obmenu-generator">
		</menu>
	</openbox_menu>
	################

In case you are using another menu generator, replace the execute command with the relevant command. If you are not using any menu generator, you may need to do something else (or just not have a menu at all, which is also fine).

### Autostart
You need to edit the `~/.config/openbox/autostart` file to run certain commands on startup. You'll need to add some basic things like the system tray panel for icons, starting these icons, starting the audio daemon, etc. You may have to add other things based on your requirements and packages you installed.

	############################################
    ## Set wallpaper to pure black
    xsetroot -bg black
	## minimal panel to provide system tray for various icons
	tint2&
	## networking icon
	nm-applet&
	## launch screensaver silently
	xscreensaver -no-splash &
	## lock desktop on hibernate by invoking the screensaver's lock function
	xss-lock -- xscreensaver-command -lock &
	## pulseaudio is more convenient than plain alsa for sound control (some Arch people do not like it)
	## this starts the daemon to which we can send commands with pactl and paplay
	pulseaudio --start &
	## show a volume icon
	volumeicon &
	## launch the login script which does cryptmount, launches emacs etc
	login-1 &
	## uncomment this line in laptops for battery icon and auto hybernate on critical power
	cbatticon -l 20 -r 10 -c "systemctl hibernate" &

	## Set up the 3x3 grid of the desktops. This requires a small program called setlayout which is put in your bin folder. I am adding the program to the repo.
	~/bin/setlayout 0 3 3 0
	############################################

#### Workspace layout
The last command in the `autostart` file needs a 50 line C program (`setlayout.c`) that has been added to the repo. You'll need to compile it using the instructions in the code, basically run `gcc -o setlayout setlayout.c -lX11`. 

The command is used to set up the structure of the workspaces; the listed command creates a 3x3 grid containing a total of 9 workspaces. You should be able to set up more of them by changing the number within the `<number>` tag in the `<desktop>` tag in the `rc.xml` file found in `~/.config/openbox/`. If that file is not present you can copy a default one from `/etc/xdg/openbox/`. Restarting of `openbox` may be required to make changes effective; that is basically logging out and logging in again.

### Keyboard shortcuts
Adding keyboard shortcuts is something that each user must do on their own. The `obkey` provides a nice small interface by which these can be added. You can add shortcuts that directly open your browser, your file manager, etc.
