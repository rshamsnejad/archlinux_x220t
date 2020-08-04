# Arch Linux setup for ECE studies on X220T

## Arch install

* `# loadkeys fr`
* `# timedatectl set-ntp true`
* `# timedatectl set-timezone Europe/Paris`
* Disk layout :
| Partition | Label | Filesystem | Size | Mount point |
| -- | -- | -- | -- | -- |
| `/dev/sda1` | EFI | FAT32 | 512M | `/efi` |
| `/dev/sda2` | ARCH-BOOT | FAT32 | 512M | `/boot` |
| `/dev/sda3` |  | LVM PV | +100% |

* LVM Layout :
| Partition | Label | Filesystem | Size | Mount point |
| -- | -- | -- | -- | -- |
| `/dev/vgarchlinux/arch-root` | ARCH-ROOT | ext4 | 30G | `/` |
| `/dev/vgarchlinux/arch-home` | ARCH-HOME | ext4 | 50G | `/home` |
| `/dev/vgarchlinux/linux-swap` | LINUX-SWAP | swap | 4G | `swap` |

* Packages (`# pacstrap /mnt`)
  * `base linux linux-firmware intel-ucode`
  * `dosfstools exfat-utils e2fsprogs ntfs-3g lvm2`
  * `networkmanager`
  * `vim`
  * `man-db man-pages texinfo`
  * `sudo bash-completion`

* `# genfstab -L /mnt >> /mnt/etc/fstab`

* Copy `hostname`, `hosts`, `locale.conf`, `vconsole.conf` from git repo's `root_files/etc` to `/mnt/etc`

* In chroot :
  * `# ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime`
  * `# hwclock --systohc`
  * Uncomment `en_US.UTF8` and `fr_FR.UTF8` from `/etc/locale.gen`
  * `# locale-gen`
  * Change in `/etc/mkinitcpio.conf` the `HOOKS` line to :
  ```
  HOOKS=(base systemd autodetect modconf block sd-lvm2 filesystems keyboard fsck)
  ```
  * `# mkinitcpio -P`
  * `# passwd` to set root password
  ##### Boot loader (rEFInd)

  * `# pacman -Sy refind`
  * `# refind-install --usedefault /dev/sda1` - This flag is needed otherwise it won't boot (X220-specific ?)
  * `# mkdir /efi/EFI/refind/drivers_x64`
  * `# cp /usr/share/refind/drivers_x64/ext4_x64.efi /efi/EFI/refind/drivers_x64`
  * Copy from git repo's `root_files/boot/refind_linux.conf` to `/boot`
  * Copy from git repo's `root_files/efi/EFI/refind/refind.conf` to `/efi/EFI/refind`

## Arch post-install

* `# cd /usr/bin && ln -s vim vi`
* Uncomment the `%sudo` line in `visudo`
* `# groupadd sudo`
* `# useradd -m -G sudo <user>`
* `# passwd <user>`
* Log out and re-log in as *\<user\>*
* `$ sudo systemctl enable NetworkManager`
* `$ sudo systemctl start NetworkManager`
* `$ sudo pacman -Syu git base-devel`
* Copy from git repo's `root_files/etc/pacman.conf` to `/etc`
* `sudo pacman -Syu`
* Import dotfiles

#### KDE Plasma install

* `$ sudo pacman -S plasma plasma-wayland-session` (Keep all defaults)
* `$ sudo pacman -S ark audiocd-kio dolphin dolphin-plugins gwenview kalarm kate kcalc kcharselect kcolorchooser kdeconnect kdenetwork-filesharing kdf kdialog kfind khelpcenter kio-extras kio-gdrive kmag knotes kolourpaint kompare konsole yakuake krdc krfb kruler ksystemlog ktimer okular print-manager spectacle svgpart zeroconf-ioslave qt5-virtualkeyboard firefox`
* `$ sudo pacman -S xf86-input-synaptics kcm-wacomtablet`
* `$ sudo systemctl enable sddm.service`
* `$ sudo localectl set-x11-keymap fr`
* `$ sudo pacman -S xdg-user-dirs`
* `$ xdg-user-dirs-update`
* `$ sudo pacman -S bluez-utils pulseaudio-bluetooth`
* `$ sudo systemctl enable bluetooth.service`
* `$ sudo touch /var/lib/sddm/.config/sddm-greeterrc`
* `$ sudo chown sddm:sddm /var/lib/sddm/.config/sddm-greeterrc`
* `$ sudo chmod 600 /var/lib/sddm/.config/sddm-greeterrc`
* Copy from git repo's `root_files/etc/sddm.conf` to `/etc`

Reboot into graphical

* System settings :
  * Input Devices
    * Keyboard
      * Layouts
        * Remove `us`, add `fr`
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

## Applications

* `sudo pacman -S atom`

## AUR helper

* Change the `MAKEFLAGS` line in `/etc/makepkg.conf` to `MAKEFLAGS="-j$(nproc)"`
* `$ mkdir ~/AUR`
* `$ cd ~/AUR`
* `$ git clone https://aur.archlinux.org/yay.git`
* `$ cd yay`
* `$ makepkg -si`

## Plymouth (pretty boot)

* `$ yay -S plymouth-git`
* `$ yay -S plymouth-theme-arch-breeze-git`
* Add `sd-plymouth` after `systemd` in the `HOOKS` line of `/etc/mkinitcpio.conf`
* Add `i915` the `MODULES` line in `/etc/mkinitcpio.conf`
* `$ sudo plymouth-set-default-theme -R arch-breeze`
* Add `quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0` to the "standard" kernel parameters in `/boot/refind_linux.conf`
* `$ sudo systemctl disable sddm.service`
* `$ sudo systemctl enable sddm-plymouth.service`

<!-- TODO :
* Wayland or Touchegg ?..
* Tablet activities

* Touch apps
  * Xournal++
  * Write
  * Notorious
  * Krita
-->
