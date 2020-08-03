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
  * `base linux linux-firmware`
  * `dosfstools exfat-utils e2fsprogs ntfs-3g lvm2`
  * `networmanager`
  * `vim`
  * `man-db man-pages texinfo`

* `# genfstab -L /mnt >> /mnt/etc/fstab`

* In chroot :
  * `# ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime`
  * `# hwclock --systohc`
  * Uncomment `en_US.UTF8` and `fr_FR.UTF8` from `/etc/locale.gen`
  * `# locale-gen`
