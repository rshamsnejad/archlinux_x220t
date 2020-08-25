# Arch Linux setup for ECE studies on X220T

## Arch install

* `# loadkeys fr`
* `# timedatectl set-ntp true`
* `# timedatectl set-timezone Europe/Paris`
* `# iwctl`
  * `[iwd]# station wlan0 scan`
  * `[iwd]# station wlan0 get-networks`
  * `[iwd]# station wlan0 connect <SSID>`

* Disk layout :

| Partition | Part. Label | FS Label | Filesystem | Size | Mount point |
| -- | -- | -- | -- | -- | -- |
| `/dev/sdb1` | EFI | EFI | FAT32 | 512M | `/efi` |
| `/dev/sdb2` | BOOT | ARCH-BOOT | FAT32 | 512M | `/boot` |
| `/dev/sdb3` | CRYPTSWAP | ARCH-SWAP | LUKS | 4G | `/dev/mapper/swap` |
| `/dev/sdb3` | CRYPTSYSTEM | ARCH-SYSTEM | BTRFS on LUKS | 100G | `/dev/mapper/system` |

* Use `cgdisk` for partitioning
* `# mkfs.fat -F 32 /dev/disk/by-partlabel/EFI -n "EFI"`
* `# mkfs.fat -F 32 /dev/disk/by-partlabel/BOOT -n "ARCH-BOOT"`
* `cryptsetup open --type plain --key-file /dev/urandom /dev/disk/by-partlabel/CRYPTSWAP swap`
* `# cryptsetup luksFormat --label "ARCH-SYSTEM" /dev/disk/by-partlabel/CRYPTSYSTEM`
* `# cryptsetup open /dev/disk/by-partlabel/CRYPTSYSTEM crypsys`

* BTRFS Layout :

| Subvolume | Mount point |
| -- | -- |
| `root` | `/` |
| `home` | `/home` |
| `snapshots` | `/.snapshots` |

* `# mkswap -L "ARCH-SWAP" /dev/mapper/swap`
* `# mkfs.btrfs --force --label "ARCH-BTRFS" /dev/mapper/system`
* `# mount -t btrfs LABEL=ARCH-BTRFS /mnt`
* `# btrfs subvolume create /mnt/root`
* `# btrfs subvolume create /mnt/home`
* `# btrfs subvolume create /mnt/snapshots`
* `# umount -R /mnt`

* `# swapon /dev/disk/by-label/ARCH-SWAP`
* `BTFRS_OPTS="defaults,x-mount.mkdir,compress=lzo,ssd,noatime"`
* `# mount -t btrfs -o subvol=root,$BTRFS_OPTS LABEL=ARCH-BTRFS /mnt`
* `# mount -t btrfs -o subvol=home,$BTRFS_OPTS LABEL=ARCH-BTRFS /mnt/home`
* `# mount -t btrfs -o subvol=snapshots,$BTRFS_OPTS LABEL=ARCH-BTRFS /mnt/.snapshots`
* `# mkdir /mnt/efi`
* `# mount /dev/disk/by-label/EFI /mnt/efi`
* `# mkdir /mnt/boot`
* `# mount /dev/disk/by-label/ARCH-BOOT /mnt/boot`


* Packages (`# pacstrap /mnt`)
  * `base linux linux-firmware intel-ucode`
  * `dosfstools exfatprogs btrfs-progs ntfs-3g`
  * `networkmanager`
  * `vim`
  * `man-db man-pages texinfo`
  * `sudo bash-completion`

* `# genfstab -L /mnt >> /mnt/etc/fstab`
* Change the `LABEL=ARCH-SWAP` line to :
```
/dev/mapper/swap    	none      	swap      	sw  	0 0
```

* `# pacman -Sy git`
* `# git clone https://github.com/rshamsnejad/archlinux_x220t.git`
* Copy `crypttab`, `hostname`, `hosts`, `locale.conf`, `vconsole.conf` from git repo's `root_files/etc` to `/mnt/etc`

* In chroot (`# arch-chroot /mnt`):
  * `# ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime`
  * `# hwclock --systohc`
  * Uncomment `en_US.UTF8` and `fr_FR.UTF8` from `/etc/locale.gen`
  * `# locale-gen`
  * Change in `/etc/mkinitcpio.conf` the `HOOKS` line to :
  ```
  HOOKS=(base systemd sd-vconsole modconf keyboard block filesystems btrfs sd-encrypt fsck)
  ```
  * `# mkinitcpio -P`
  * `# passwd` to set root password

  ##### Boot loader (rEFInd)

  * `# pacman -Sy refind`
  * `# refind-install --usedefault /dev/sdb1` - This flag is needed otherwise it won't boot (X220-specific ?)
  * Copy from git repo's `root_files/boot/refind_linux.conf` to `/boot`
  * Copy from git repo's `root_files/efi/EFI/BOOT/refind.conf` to `/efi/EFI/BOOT`


## Arch post-install

* `# (cd /usr/bin && ln -s vim vi)`
* Uncomment the `%sudo` line in `visudo`
* `# groupadd sudo`
* `# useradd -m -G sudo <user>`
* `# passwd <user>`
* Log out and re-log in as *\<user\>*
* `$ sudo systemctl enable NetworkManager`
* `$ sudo systemctl start NetworkManager`
* `$ nmtui` and activate Wi-Fi
* `$ sudo pacman -Syu git base-devel`
* `$ mkdir -p ~/dev/github`
* `$ cd ~/dev/github && git clone https://github.com/rshamsnejad/archlinux_x220t.git`
* Copy from git repo's `root_files/etc/pacman.conf` to `/etc`
* `$ sudo pacman -Syu`
* Import dotfiles
* Uncomment and set `DefaultTimeoutStopSec=20s` in `/etc/systemd/system.conf`

## Mirror upgrade

* `$ sudo pacman -S reflector`
* `$ sudo mkdir /etc/pacman.d/hooks`
* Copy from git repo's `root_files/etc/pacman.d/hooks/reflector.hook` to `/etc/pacman.d/hooks`
* Copy from git repo's `root_files/etc/xdg/reflector/reflector.conf` to `/etc/xdg/reflector/`
* `$ sudo systemctl enable reflector.timer`

## AUR helper

* Change the `MAKEFLAGS` line in `/etc/makepkg.conf` to `MAKEFLAGS="-j$(nproc)"`
* `$ mkdir ~/AUR`
* `$ cd ~/AUR`
* `$ git clone https://aur.archlinux.org/yay.git`
* `$ cd yay`
* `$ makepkg -si`

## TLP (power saving)

* `$ sudo pacman -S tlp acpi_call tp_smapi`
* Copy from git repo's `root_files/etc/tlp.conf` to `/etc`
* `$ sudo systemctl mask systemd-rfkill.service`
* `$ sudo systemctl mask systemd-rfkill.socket`
* `$ sudo systemctl enable tlp.service`

#### KDE Plasma install

* `$ sudo pacman -S xf86-video-intel`
* `$ sudo pacman -S plasma` (Keep all defaults)
* `$ sudo pacman -S ark unrar unzip audiocd-kio dolphin dolphin-plugins gwenview kate kcalc kcharselect kcolorchooser kdeconnect kdenetwork-filesharing kdf kdialog kfind khelpcenter kio-extras kio-gdrive kmag kolourpaint kompare konsole yakuake krdc krfb kruler ksystemlog ktimer okular print-manager partitionmanager packagekit-qt5 spectacle svgpart zeroconf-ioslave qt5-virtualkeyboard firefox vlc`
* `$ sudo pacman -S xf86-input-synaptics kcm-wacomtablet`
* `$ sudo systemctl enable sddm.service`
* `$ sudo localectl set-x11-keymap fr`
* `$ sudo touch /var/lib/sddm/.config/sddm-greeterrc`
* `$ sudo chown sddm:sddm /var/lib/sddm/.config/sddm-greeterrc`
* `$ sudo chmod 600 /var/lib/sddm/.config/sddm-greeterrc`
* Copy from git repo's `root_files/etc/sddm.conf` to `/etc`
* `$ sudo pacman -S xdg-user-dirs`
* `$ xdg-user-dirs-update`
* `$ sudo pacman -S bluez-utils pulseaudio-bluetooth`
* `$ sudo systemctl enable bluetooth.service`

Reboot into graphical

* System settings :
  * Input Devices
    * Keyboard
      * Advanced
        * Tick **Key sequence to kill the X server**
    * Touchpad
      * Taps
        * Set the **Tap to click** drop-downs
      * Enable/Disable Touchpad
        * Tick **Disable touchpad when mouse is plugged in**
    * Graphic Tablet
      * Stylus
        * Button 2 : **Right Mouse Button Click**
      * Tablet
        * Orientation
          * Untick **Auto-rotate with screen** (conflicts with the rotate script)
      * Touch
        * Untick **Enable touch**
  * Account Details
    * Configure user, and tick **Enable administrator privileges for this user**
  * Global Theme
    * Choose **Breeze Dark**
  * Workspace Behavior
    * General Behavior
      * Tick **Double-click to open files and folders**
    * Screen Edges
      * Disable all
    * Touch Screen
      * Disable all
    * Screen Locking
      * Appearance
        * Set background
    * Virtual Desktops
      * Set Main+Aux
  * Startup and Shutdown
    * Login Screen
      * Theme
        * Choose "Breeze"
        * Set background
      * Advanced
        * Click **Sync**
    * Autostart
      * Add **Yakuake**
    * Desktop Session
      * Tick **Start with an empty session**
    * Splash Screen
      * Disable
  * Regional Settings
    * Formats
      * Set **Region** to **USA**, everything else to **France**
    * Date & Time
      * Tick **Set date and time automatically**
  * Online accounts
    * Set up Google Drive
  * User Feedback
    * Set at least **Basic System Information**
  * Display and Monitor
    * Compositor
      * Set **Rendering backend** to **OpenGL3.1**
    * Night Color
      * Activate and set at **3400 K**

## Screen rotation

* `$ sudo pacman -S xorg-xrandr`
* `$ sudo mkdir -p /opt/bin`
* `$ sudo groupadd system`
* `$ sudo gpasswd -a <user> system`
* Copy git repo's `root_files/opt/bin/thinkpad_rotate.sh` to `/opt/bin/`
* `$ sudo chown root:system /opt/bin/thinkpad_rotate.sh`
* `$ sudo chmod 754 /opt/bin/thinkpad_rotate.sh`
* Copy git repo's `root_files/etc/profile.d/path.sh` to `/etc/profile.d/`
* System Settings
  * Shortcuts
    * Custom Shortcuts
      * **Edit > New > Global Shortcut > Command/URL**
        * Name : **Screen rotation**
        * Assign to screen button
        * Command is `/opt/bin/thinkpad_rotate.sh`

## On-screen keyboard

* `$ sudo pacman -S onboard`
* System Settings
  * Startup and Shutdown
    * Autostart
      * Add **Onboard**
* Onboard settings
  * General
    * Tick **Start Onboard hidden**
    * Untick **Show when locking the screen**
  * Window
    * Window options
      * Tick **Dock to screen edge**
    * Transparency
      * Window : 0
      * Background : 40
  * Layout
    * **Compact**
  * Theme
    * **Blackboard**
      * Customize theme
        * Labels
          * Font : **FreeSans**
          * Label Override
           * Super key : **"Sup"**

## rEFInd Theme and customization

* `$ sudo mkdir /efi/EFI/BOOT/themes`
* `$ sudo git clone https://github.com/rshamsnejad/refind-ambience.git /efi/EFI/BOOT/themes/refind-ambience`
* Add at the end of `/efi/EFI/BOOT/refind.conf` :
```
include themes/refind-ambience/theme.conf
```
* `$ sudo pacman -S edk2-shell`
* `$ sudo cp /usr/share/edk2-shell/x64/Shell_Full.efi /efi/EFI/tools/shellx64.efi`
* `$ yay -S memtest86-efi`
* `$ sudo cp /usr/share/memtest86-efi/bootx64.efi /efi/EFI/tools/memtest86x64.efi`
* `(cd /tmp && curl -O https://deac-ams.dl.sourceforge.net/project/gptfdisk/gptfdisk/1.0.4/gdisk-binaries/gdisk-efi-1.0.4.zip)`
* `$ sudo unzip -j /tmp/gdisk-efi-*.zip gdisk-efi/gdisk_x64.efi -d /efi/EFI/tools/`

## Plymouth (pretty boot)

* `$ yay -S plymouth-git`
* `$ yay -S plymouth-theme-arch-breeze-git`
* In the `HOOKS` line of `/etc/mkinitcpio.conf` :
  * Add `plymouth` after `udev`
  * Change `encrypt` for `plymouth-encrypt`
* Add `i915` in the `MODULES` line of `/etc/mkinitcpio.conf`
* `$ sudo plymouth-set-default-theme -R arch-breeze`
* Add `quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0` to the "standard" kernel parameters in `/boot/refind_linux.conf`
* `$ sudo systemctl disable sddm.service`
* `$ sudo systemctl enable sddm-plymouth.service`

## Applications

* `$ sudo pacman -S atom`
* `$ sudo pacman -S xournalpp texlive-latexextra`
* `$ sudo pacman -S krita`
* `$ curl http://www.styluslabs.com/write/write300.tar.gz -o /tmp/write300.tar.gz` (There's an AUR package, but the md5sums are wrong at the time of writing. See the INSTALL file for installation instructions)
* `$ sudo pacman -S geogebra`
* `$ sudo pacman -S libreoffice-fresh hunspell-fr hunspell-en_US`
* `$ sudo pacman -S calibre`
* `$ sudo pacman -S retext`
* `$ sudo pacman -S basket`
* `$ sudo pacman -S freecad-appimage librecad kicad kicad-library`
* `$ yay -S logisim-evolution-git ttf-ms-fonts`
* `$ sudo pacman -S pulseview`
* `$ yay -S ltspice`
* `$ yay -S yed`
* `$ sudo pacman -S anki`

## Shared VeraCrypt drive with Windows

* `$ sudo pacman -S veracrypt`
* `$ sudo mkdir /mnt/SHARED`
* `$ sudo groupadd veracrypt`
* `$ sudo gpasswd -a <user> veracrypt`
* `$ sudo visudo`
  * Add `%veracrypt ALL=(ALL) NOPASSWD:/usr/bin/veracrypt`  
* In VeraCrypt GUI :
  * Click **Slot 1**
  * Click **Select Device...**
    * Choose `/dev/sda1`
    * Validate
      * Enter passphrase
      * Under **Options** :
      * Mount at directory : `/mnt/SHARED`
      * Validate
  * Right-click **Slot 1** and choose **Add to Favorites**
* In System Settings :
  * Startup and Shutdown
    * Autostart
      * Add Program...
        * Enter `/usr/bin/veracrypt --auto-mount=favorites --use-dummy-sudo-password`



<!-- TODO :

* Tablet activities
* Fan control

-->
