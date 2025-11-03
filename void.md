# Void on a Pixelbook 2017 Eve
## General
dbus nerd-fonts noto-fonts-ttf brightnessctl curl python xdg-desktop-portal-gtk tlp seatd socklog-void 

## Graphics
void-repo-nonfree intel-gpu-tools intel-ucode intel-video-accel mesa-vulkan-intel mesa-dri vulkan-loader 

## Keyboard 
keyd
(run script)
(dotter files)


## Utilities
Waybar alacritty btop fuzzel git niri mako uv tmux ripgrep fzf neovim jq cliphist tree

## Bluetooth
bluetui bluez

## Wireless Network stack
iwd 
impala
(maybe don't need to modify iwd config as impala may do it for us)

## Audio
# 1. install packages
sudo xbps-install -S alsa-utils sof-firmware pipewire wireplumber [alsa-pipewire maybe this, try without]

run pipewire in niri

# 3. chromebook audio setup
git clone https://github.com/WeirdTreeThing/chromebook-linux-audio
cd chromebook-linux-audio && sudo ./setup-audio eve

# 4. modprobe configs (not sure if I need these, may help with audio jumping)
sudo tee /etc/modprobe.d/snd-avs.conf >/dev/null <<EOF
options snd-intel-dspcfg dsp_driver=4
options snd-soc-avs ignore_fw_version=1
options snd-soc-avs obsolete_card_names=1
EOF
echo "options snd_soc_avs power_save=0" | sudo tee /etc/modprobe.d/avs-nosuspend.conf
sudo dracut -f

# 5. disable ALSA service
sudo rm -f /var/service/alsa

# Instructions here:
https://docs.voidlinux.org/config/media/pipewire.html

### Old audio below
Run Script
sudo xbps-install -S pipewire alsa-utils alsa-plugins alsa-ucm-conf
/etc/asound.conf # to set the default output device
