# Void on a Pixelbook 2017 Eve
## System packages
sudo xbps-install dbus nerd-fonts noto-fonts-ttf brightnessctl curl python xdg-desktop-portal-gtk tlp seatd socklog-void 

## Graphics
sudo xbps-install void-repo-nonfree intel-gpu-tools intel-ucode intel-video-accel mesa-vulkan-intel mesa-dri vulkan-loader 

## Keyboard 
sudo xbps-install keyd
(run script)
(dotter files)
Modify keyd service, remove udev check, add short sleep

## Utilities
sudo xbps-install Waybar alacritty btop fuzzel git niri mako uv tmux ripgrep fzf neovim jq cliphist tree wbg

## Bluetooth
sudo xbps-install bluetui bluez

## Kernel command line
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 rd.udev.log_level=3 rd.luks=0 rd.lvm=0 rd.md=0 rd.dm=0 rootfstype=ext4 i915.enable_psr=1 i915.enable_dc=2 i915.enable_fbc=1 noresume mitigations=off nmi_watchdog=0"

## Wireless Network stack
sudo xbps-install iwd impala
(maybe don't need to modify iwd config as impala may do it for us)

## Audio
sudo xbps-install -S alsa-utils sof-firmware alsa-ucm-conf pipewire wireplumber [alsa-plugins alsa-pipewire maybe this, try without]
git clone https://github.com/WeirdTreeThing/chromebook-linux-audio
cd chromebook-linux-audio && sudo ./setup-audio -b eve
Follow Instructions here: https://docs.voidlinux.org/config/media/pipewire.html
sudo rm -f /var/service/alsa to prevent alsa from shifting the volume

