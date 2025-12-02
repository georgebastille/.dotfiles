# Void on a Pixelbook 2017 Eve
## System packages
sudo xbps-install dbus nerd-fonts noto-fonts-ttf brightnessctl curl python xdg-desktop-portal-gtk tlp seatd socklog-void wbg

## Graphics
sudo xbps-install void-repo-nonfree intel-gpu-tools intel-ucode intel-video-accel mesa-vulkan-intel mesa-dri vulkan-loader 

## Keyboard 
sudo xbps-install keyd
(run script)
(dotter files)
Modify keyd service, remove udev check, add short sleep

## Utilities
sudo xbps-install Waybar alacritty btop fuzzel git niri mako uv tmux ripgrep fzf neovim jq cliphist tree

## Bluetooth
sudo xbps-install bluetui bluez

## Kernel command line

GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 rd.udev.log_level=3 rd.luks=0 rd.lvm=0 rd.md=0 rd.dm=0 rootfstype=ext4 i915.enable_psr=1 i915.enable_dc=2 i915.enable_fbc=1 noresume mitigations=off nmi_watchdog=0"

## Direct Boot
sudo xbps-install systemd-boot-efistub dracut-uefi
sudo xbps-alternatives -s dracut-uefi 
./dotter deploy
sudo efibootmgr -c -d /dev/mmcblk0 -p 1 -L "Void Current" -l '\EFI\void\void-linux-current.efi'
sudo efibootmgr -c -d /dev/mmcblk0 -p 1 -L "Void Previous" -l '\EFI\void\void-linux-previous.efi'
Then change the boot order (look at the man page)


## Wireless Network stack
sudo xbps-install iwd impala
(maybe don't need to modify iwd config as impala may do it for us)

## Printing
sudo xbps-install cups hplip system-config-printer
(Find IP of printer)
sudo hp-setup (ip address)

## Audio
sudo xbps-install -S alsa-utils sof-firmware alsa-ucm-conf pipewire wireplumber [alsa-plugins alsa-pipewire maybe this, try without]
git clone https://github.com/WeirdTreeThing/chromebook-linux-audio
cd chromebook-linux-audio && sudo ./setup-audio -b eve
Follow Instructions here: https://docs.voidlinux.org/config/media/pipewire.html
sudo rm -f /var/service/alsa to prevent alsa from shifting the volume
sudo alsactl store to fix volume for next boot

## nodejs
Install with Node Version Manager (https://github.com/nvm-sh/nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

## void services
acpid        agetty-tty2  agetty-tty4  agetty-tty6  dbus  keyd       openntpd  socklog-unix  udevd
agetty-tty1  agetty-tty3  agetty-tty5  bluetoothd   iwd   nanoklogd  seatd     tlp           uuidd


