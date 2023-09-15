#! bin/bash

# Check if run as a root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

echo $username
echo $builddir

# Update packages list and update system
apt update
apt upgrade -y
echo "System Updated"

# Install nala
apt install nala -y
nala fetch
nala update
nala upgrade
echo "Nala Installed"

nala install apt-transport-https curl wget neovim  -y

# Making .config and Moving config files and background to Pictures
cd $builddir

# Creates config directories
config=(.config .fonts Pictures )
for key in "${config[@]}" 
do
	DIR=/home/$username/$key
	[ ! -d "$DIR" ] && mkdir -p $DIR & echo "Directory created $DIR"
done

cp -R dotnetconfig/* /home/$username/.config
mv ./Pictures/*.png ./Pictures/*.jpg /home/$username/Pictures
cp ./xinitrc /home/$username
mv ./user-dirs.dirs /home/$username/$config[0]
chown -R $username:$username /home/$username

# Install Font 
cd $builddir 
nala install fonts-font-awesome
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /home/$username/.fonts
mv dotfonts/fontawesome/otfs/*.otf /home/$username/.fonts/
chown $username:$username /home/$username/.fonts/*

# Reloading Font
fc-cache -vf
# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip
echo "Fonts Installed"

# Installing Programs
nala install xorg sxhkd bspwm rofi nitrogen thunar kitty neofetch htop picom pipewire wireplumbler
sudo systemctl --user --now enable wireplumber.service

# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
echo "LazyVim Installed"

# Install Browser
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
nala update
nala install brave-browser -y
echo "Brave Installed"


nala autoremove
nala autopurge

printf "\e[1;32mYou can now reboot! Thanks you.\e[0m\n"


