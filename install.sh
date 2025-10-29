#!/bin/bash
# i3wm ThinkPad T14 Gen 2 setup script for Debian
# Run as root: sudo bash setup_i3_t14.sh

set -e

echo "=== Updating system ==="
apt update && apt upgrade -y

echo "=== Installing core packages ==="
apt install -y \
    i3 i3status i3lock feh picom rofi kitty \
    network-manager network-manager-gnome blueman \
    pulseaudio pavucontrol alsa-utils playerctl \
    brightnessctl acpi acpi-support \
    git curl wget unzip \
    xrandr arandr \
    polybar \
    fonts-font-awesome \
    firmware-linux firmware-linux-nonfree firmware-iwlwifi \
    build-essential

echo "=== Enabling services ==="
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl start NetworkManager
systemctl start bluetooth

echo "=== Installing latest Firefox (non-ESR) ==="
# Remove ESR if installed
apt remove -y firefox-esr || true
# Download latest release directly from Mozilla
cd /opt
wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
tar xjf firefox.tar.bz2
ln -sf /opt/firefox/firefox /usr/local/bin/firefox
rm firefox.tar.bz2
echo "Firefox installed at /opt/firefox"

echo "=== Setting up Polybar ==="
mkdir -p ~/.config/polybar
cat > ~/.config/polybar/config.ini << 'EOF'
[bar/main]
width = 100%
height = 28
background = #222
foreground = #dfdfdf
font-0 = monospace:style=Bold:pixelsize=10;2
modules-left = xworkspaces
modules-center = date
modules-right = pulseaudio bluetooth network battery

[module/xworkspaces]
type = internal/xworkspaces

[module/date]
type = internal/date
interval = 5
format = %Y-%m-%d %H:%M

[module/pulseaudio]
type = internal/pulseaudio
format-volume = <label-volume> <bar-volume>
label-volume = VOL %percentage%%
label-muted = 🔇 muted
use-ui = true

[module/bluetooth]
type = custom/script
exec = bluetoothctl devices | grep -q "Device" && echo "" || echo ""
interval = 10

[module/network]
type = internal/network
interface = wlan0
format-connected = "  %essid% %local_ip%"
format-disconnected = "睊 No Wi-Fi"

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
full-at = 98
format-full = "  %percentage%%"
format-charging = " %percentage%%"
format-discharging = "  %percentage%%"
EOF

echo "=== Creating i3 config ==="
mkdir -p ~/.config/i3
cat > ~/.config/i3/config << 'EOF'
set $mod Mod1

font pango:monospace 10

exec --no-startup-id nm-applet
exec --no-startup-id blueman-applet
exec --no-startup-id picom --experimental-backends
exec --no-startup-id polybar main
exec --no-startup-id /usr/bin/feh --bg-fill /usr/share/backgrounds/xfce/xfce-blue.jpg

bindsym $mod+Return exec kitty
bindsym $mod+d exec rofi -show drun
bindsym $mod+Shift+e exec "i3-msg exit"

# Volume controls
bindsym XF86AudioRaiseVolume exec "pactl set-sink-volume @DEFAULT_SINK@ +5%"
bindsym XF86AudioLowerVolume exec "pactl set-sink-volume @DEFAULT_SINK@ -5%"
bindsym XF86AudioMute exec "pactl set-sink-mute @DEFAULT_SINK@ toggle"

# Brightness controls
bindsym XF86MonBrightnessUp exec "brightnessctl set +10%"
bindsym XF86MonBrightnessDown exec "brightnessctl set 10%-"

# Lock screen
bindsym $mod+Shift+l exec i3lock

# Reload config
bindsym $mod+Shift+r restart
EOF

echo "=== Setting up Rofi theme ==="
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/config.rasi << 'EOF'
configuration {
    modi: "drun,run";
    font: "monospace 10";
    show-icons: true;
    theme: "Arc-Dark";
}
EOF

echo "=== Enabling sound ==="
systemctl --user enable pulseaudio
systemctl --user start pulseaudio

echo "=== Setup complete ==="
echo "Reboot your system and select i3 from the login manager."
