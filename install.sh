#!/bin/bash

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Core system utilities
sudo apt install -y sudo network-manager network-manager-gnome \
    lightdm lightdm-gtk-greeter i3 i3status feh picom lxappearance \
    gnome-keyring xclip brightnessctl xrandr arandr autorandr \
    rofi kitty thunar unclutter xsel

# Audio (PipeWire + PulseAudio compatibility)
sudo apt install -y pipewire pipewire-audio-client-libraries \
    wireplumber pavucontrol alsa-utils
# Polybar and dependencies
sudo apt install -y polybar playerctl pulseaudio-utils bluez blueman
# Enable services
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
# Optional: Create basic polybar config with power, volume, and bluetooth modules
mkdir -p ~/.config/polybar
cat << 'EOF' > ~/.config/polybar/config.ini
[bar/example]
width = 100%
height = 30
modules-left = i3
modules-right = volume bluetooth powermenu
[module/i3]
type = internal/i3

[module/volume]
type = internal/pulseaudio
format-volume = <label-volume>
label-volume =  %percentage%%

[module/bluetooth]
type = custom/script
exec = bluetoothctl show | grep "Powered: yes" && echo " On" || echo " Off"
interval = 10

[module/powermenu]
type = custom/menu
label-open = 
menu-0-0 = Reboot
menu-0-0-exec = systemctl reboot
menu-0-1 = Shutdown
menu-0-1-exec = systemctl poweroff
EOF

echo "✅ All packages installed. Reboot to start using i3wm with LightDM."
