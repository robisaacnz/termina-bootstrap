#!/bin/bash

echo -e "[👢] Chrome OS Termina bootstrap is running."

echo -e "[👢] Updating package keys."
sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
curl -sL https://packagecloud.io/shiftkey/desktop/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/shiftkey/desktop/any/ any main" > /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list'
echo -e "[👢] Package keys updated.\n"

echo -e "[👢] Installing pending updates."
sudo apt -y autoremove && sudo apt -y update && sudo apt -y upgrade
echo -e "[👢] Updates installed.\n"

echo -e "[👢] Installing VS Code."
curl -sL "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
sudo apt install -y ./vscode.deb && rm ./vscode.deb
echo -e "[👢] VS Code installed.\n"

echo -e "[👢] Shortening VS Code display name."
sudo sed -i 's/Visual Studio Code/Code/g' /usr/share/applications/code.desktop
sudo touch /usr/share/applications/.garcon_trigger
echo -e "[👢] VS Code display name shortened.\n"

# Add basic settings for VS Code
if [ ! -f "$HOME/.config/Code/User/settings.json" ]; then
  echo -e "[👢] Adding basic settings for VS Code."
  echo -e "{
  \"workbench.colorTheme\": \"Default Light+\",
  \"window.titleBarStyle\": \"custom\",
  \"window.zoomLevel\": 0.5
}" > $HOME/.config/Code/User/settings.json
  echo -e "[👢] VS Code settings added.\n"
else
  echo -e "[👢] VS Code settings already exist, skipping.\n"
fi

echo -e "[👢] Installing GitHub Desktop."
sudo apt install -y github-desktop
echo -e "[👢] GitHub Desktop installed."

# Install flatpak
# Required to install Apostrophe
# sudo apt install -y flatpak && sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Apostrophe
# Not installed for now due to font rendering bug
# https://bugs.chromium.org/p/chromium/issues/detail?id=1029542
# sudo flatpak install -y org.gnome.gitlab.somas.Apostrophe

echo -e "[👢] Installing useful debian packages."
sudo apt install -y aptitude dnsutils mesa-utils w3m nano
echo -e "[👢] Useful debian packages installed.\n"

# Make URLs from linux apps open in Chrome
if [ ! -f "/usr/share/applications/garcon.desktop" ]; then
  echo -e "[👢] Configuring URLs to open in Chrome."
  echo -e "[Desktop Entry]
Type=Application
Name=Garcon URL Handler
NoDisplay=true
Exec=/usr/bin/garcon-url-handler
Path=/usr/bin/" | sudo tee /usr/share/applications/garcon.desktop > /dev/null
original_browser=$BROWSER
unset BROWSER
xdg-settings set default-web-browser garcon.desktop
export BROWSER=$original_browser
echo -e "[👢] URLs are configured to open in Chrome.\n"
else
  echo -e "[👢] URL handler configuration already exists, skipping.\n"
fi

# Enable Chrome OS window management from keyboard in linux apps
if [ ! -f "$HOME/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf" ]; then
echo -e "[👢] Setting window management overrides."
mkdir -p .config/systemd/user/sommelier@.service.d/
mkdir -p .config/systemd/user/sommelier-x@.service.d/
echo -e "[Service]
Environment=\"SOMMELIER_FRAME_COLOR=#F2F2F2\"
Environment=\"SOMMELIER_ACCELERATORS=Super_L,<Alt>tab,<Alt>bracketleft,<Alt>bracketright,<Alt>minus,<Alt>equal\"" > $HOME/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf
echo -e "[Service]
Environment=\"SOMMELIER_FRAME_COLOR=#F2F2F2\"
Environment=\"SOMMELIER_ACCELERATORS=Super_L,<Alt>tab,<Alt>bracketleft,<Alt>bracketright,<Alt>minus,<Alt>equal\"" > $HOME/.config/systemd/user/sommelier-x@.service.d/cros-sommelier-override.conf
systemctl --user daemon-reload
systemctl --user restart sommelier-x@0.service
echo -e "[👢] Window management overrides are set.\n"
else
echo -e "[👢] Window management overrides already exist, skipping.\n"
fi

# Finished
echo -e "[👢] All done. Reboot or restart the container."
