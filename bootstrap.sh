#!/bin/bash

# Update package keys
sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
curl -sL https://packagecloud.io/shiftkey/desktop/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/shiftkey/desktop/any/ any main" > /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list'

# Install all pending updates
sudo apt -y autoremove && sudo apt -y update && sudo apt -y upgrade

# Install VS Code
curl -sL "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
sudo apt install -y ./vscode.deb && rm ./vscode.deb

# Patch VS Code to shorten display name
sudo sed -i 's/Visual Studio Code/Code/g' /usr/share/applications/code.desktop

# Add basic settings for VS Code
if [ ! -f "$HOME/.config/Code/User/settings.json" ]; then
  echo -e "{
  \"workbench.colorTheme\": \"Default Light+\",
  \"window.titleBarStyle\": \"custom\",
  \"window.zoomLevel\": 0.5
}" > $HOME/.config/Code/User/settings.json
fi

# Install GitHub Desktop
sudo apt install -y github-desktop

# Install flatpak
# Required to install Apostrophe
# sudo apt install -y flatpak && sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Apostrophe
# Not installed for now due to font rendering bug
# https://bugs.chromium.org/p/chromium/issues/detail?id=1029542
# sudo flatpak install -y org.gnome.gitlab.somas.Apostrophe

# Install other useful things
sudo apt install -y aptitude dnsutils mesa-utils w3m nano

# Make URLs from linux apps open in Chrome
if [ ! -f "/usr/share/applications/garcon.desktop" ]; then
  echo -e "[Desktop Entry]
Type=Application
Name=Garcon URL Handler
NoDisplay=true
Exec=/usr/bin/garcon-url-handler
Path=/usr/bin/" | sudo tee /usr/share/applications/garcon.desktop > /dev/null
fi
original_browser=$BROWSER
unset BROWSER
xdg-settings set default-web-browser garcon.desktop
export BROWSER=$original_browser

# Enable Chrome OS window management from keyboard in linux apps
# Still needs a way to pass Alt+Tab from fullscreen linux apps
# keycode 23 (keysym 0xff09, Tab)
if [ ! -f "$HOME/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf" ]; then
mkdir -p .config/systemd/user/sommelier@.service.d/
mkdir -p .config/systemd/user/sommelier-x@.service.d/
echo -e "[Service]
Environment=\"SOMMELIER_ACCELERATORS=Super_L,<Alt>bracketleft,<Alt>bracketright,<Alt>minus,<Alt>equal\"" > $HOME/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf
echo -e "[Service]
Environment=\"SOMMELIER_ACCELERATORS=Super_L,<Alt>bracketleft,<Alt>bracketright,<Alt>minus,<Alt>equal\"" > $HOME/.config/systemd/user/sommelier-x@.service.d/cros-sommelier-override.conf
fi

# Finished
echo All done. Reboot or restart the container.
