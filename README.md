# Fedora workstation config
My Fedora config (Workstation edition)

Adapted from [aaaaadrien/fedora-config](https://github.com/aaaaadrien/fedora-config)

## Instructions
Clone this repository

```
cd $HOME
git clone https://github.com/ajacquey/fedora-config
cd fedora-config
```

Allow execution mode of the script:

```
chmod +x config-fedora.sh
```

Execute the script (it will take a while, it's normal)

```
sudo ./config-fedora.sh
```

## Additional packages to manually install
### Zoom
Download and install the rpm package:

```
cd ~/Downloads
wget https://zoom.us/client/5.16.10.668/zoom_x86_64.rpm
sudo dnf install ./zoom_x86_64.rpm
```

### Proton VPN
Download and install the rpm package:

```
cd ~/Downloads
wget https://repo.protonvpn.com/fedora-39-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.1-2.noarch.rpm
sudo dnf install ./protonvpn-stable-release-1.0.1-2.noarch.rpm
sudo dnf install --refresh proton-vpn-gnome-desktop
```

### Proton Mail Bridge
Download and install the rpm package:

```
cd ~/Downloads
wget https://proton.me/download/bridge/protonmail-bridge-3.6.1-2.x86_64.rpm
sudo dnf install ./protonmail-bridge-3.6.1-2.x86_64.rpm
```

### Microsoft Visual Studio Code
Download and install the rpm package:

```
cd ~/Downloads
wget https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64
sudo dnf install ./code-1.84.2-1699528436.el7.x86_64.rpm
```

## Terminal setup
### Download and install Meslo Nerd Font
Download the fonts:

```
cd ~/Downloads
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip
unzip Meslo.zip -d ~/.fonts
fc-cache -fv
```
### Install Oh my zsh
See https://ohmyz.sh/#install for updates

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Install powerlevel10k

See https://github.com/romkatv/powerlevel10k#installation for updates


```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Set `ZSH_THEME="powerlevel10k/powerlevel10k"` in `~/.zshrc`.

Or copy the `/zshrc` file provided here :

```
cd ~/fedora-config
cp ./.zshrc ~/.zshrc
```
