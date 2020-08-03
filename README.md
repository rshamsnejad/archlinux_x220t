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
* `$ sudo pacman -S ark audiocd-kio dolphin dolphin-plugins gwenview kalarm kate kcalc kcharselect kcolorchooser kdeconnect kdenetwork-filesharing kdf kdialog kfind khelpcenter kio-extras kio-gdrive kmag knotes kolourpaint kompare konsole yakuake krdc krfb kruler ksystemlog ktimer okular print-manager spectacle svgpart zeroconf-ioslave firefox`
* `$ sudo pacman -S xf86-input-synaptics kcm-wacomtablet`
* `$ sudo systemctl enable sddm.service`
* `$ sudo localectl set-x11-keymap fr`
* `$ sudo pacman -S xdg-user-dirs`
* `$ xdg-user-dirs-update`
* `$ sudo pacman -S bluez-utils pulseaudio-bluetooth`
* `$ sudo systemctl enable bluetooth.service`

