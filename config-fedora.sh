#!/bin/bash

#################
### VARIABLES ###
#################
CODEC="vlc gstreamer1-plugin-openh264 mozilla-openh264"
GNOMECOMP="gnome-extensions-app gnome-shell-extension-dash-to-dock gnome-shell-extension-appindicator gnome-shell-extension-system-monitor-applet gnome-themes-extra"
LATEX="texlive-scheme-full"
#####################
### END VARIABLES ###
#####################

# Test if root
if [[ $(id -u) -ne "0" ]]
then
	echo -e "\033[31mERROR\033[0m Launch this script with sudo"
	exit 1;
fi

#################
### FUNCTIONS ###
#################

check_cmd()
{
    if [[ $? -eq 0 ]]
    then
        echo -e "\033[32mOK\033[0m"
    else
        echo -e "\033[31mERREUR\033[0m"
    fi
}

check_repo_file()
{
	if [[ -e "/etc/yum.repos.d/$1" ]]
	then
		return 0
	else
		return 1
	fi
}

check_pkg()
{
	rpm -q "$1" > /dev/null
}
add_pkg()
{
	dnf install -y --nogpgcheck "$1" > /dev/null
}
del_pkg()
{
	dnf autoremove -y "$1" > /dev/null
}
swap_pkg()
{
	dnf swap -y "$1" "$2" --allowerasing > /dev/null 2>&1
}
check_flatpak()
{
	flatpak info "$1" > /dev/null 2>&1
}
add_flatpak()
{
	flatpak install flathub --noninteractive -y "$1" > /dev/null 2>&1
}
del_flatpak()
{
	flatpak uninstall --noninteractive -y "$1" > /dev/null && flatpak uninstall --unused  --noninteractive -y > /dev/null
}
refresh_cache()
{
	dnf check-update fedora-release > /dev/null 2>&1
}
check_updates_rpm()
{
	yes n | dnf upgrade
}
check_updates_flatpak()
{
	yes n | flatpak update
}
#####################
### END FUNCTIONS ###
#####################

###############
### PROGRAM ###
###############
HERE=$(dirname "$0")

## CHECK-UPDATES
if [[ "$1" = "check" ]]
then
	echo -n "01- - Cache refresh: "
	refresh_cache
	check_cmd

	echo "02- - RPM updates available: "
	echo -e "\033[36m"
	check_updates_rpm
	echo -e "\033[0m"

	echo "03- - FLATPAK updates available: "
	echo -e "\033[36m"
	check_updates_flatpak
	echo -e "\033[0m"

	exit;
fi

### CONF DNF
echo "01- Check DNF configuration"
if [[ $(grep -c 'fastestmirror=' /etc/dnf/dnf.conf) -lt 1 ]]
then
	echo -n "- - - Correction fastest mirrors: "
	echo "fastestmirror=true" >> /etc/dnf/dnf.conf
	check_cmd
fi
if [[ $(grep -c 'max_parallel_downloads=' /etc/dnf/dnf.conf) -lt 1 ]]
then
	echo -n "- - - Correction parallel downloads: "
	echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
	check_cmd
fi
if [[ $(grep -c 'countme=' /etc/dnf/dnf.conf) -lt 1 ]]
then
	echo -n "- - - Correction statistics: "
	echo "countme=false" >> /etc/dnf/dnf.conf
	check_cmd
fi
if [[ $(grep -c 'deltarpm=' /etc/dnf/dnf.conf) -lt 1 ]]
then
    echo -n "- - - Correction deltarpm deactivated: "
    echo "deltarpm=false" >> /etc/dnf/dnf.conf
    check_cmd
fi

### UPDATE RPM
echo -n "02- Update DNF system: "
dnf update -y > /dev/null  2>&1
check_cmd

### UPDATE FP
echo -n "03- Update FLATPAK system: "
flatpak update --noninteractive > /dev/null  2>&1
check_cmd

### CONFIG DEPOTS
echo "04- Check repositories configuration"
## RPMFUSION
if ! check_pkg rpmfusion-free-release
then
	echo -n "- - - Install RPM Fusion Free : "
	add_pkg "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
	check_cmd
fi
if ! check_pkg rpmfusion-nonfree-release
then
	echo -n "- - - Install RPM Fusion Nonfree : "
	add_pkg "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
	check_cmd
fi

## INSTALL CODECS
echo "05- Check Codecs"
for p in $CODEC
do
	if ! check_pkg "$p"
	then
		echo -n "- - - Installation codecs $p : "
		add_pkg "$p"
		check_cmd
	fi
done

### INSTALL GNOME TOOLS
echo "06- Check GNOME components"
for p in $GNOMECOMP
do
	if ! check_pkg "$p"
	then
		echo -n "- - - Install GNOME component $p : "
		add_pkg "$p"
		check_cmd
	fi
done

## INSTALL TEXLIVE
echo "07- Check TEXLIVE components"
for p in $LATEX
do
	if ! check_pkg "$p"
	then
		echo -n "- - - Install TEXLIVE component $p : "
		add_pkg "$p"
		check_cmd
	fi
done

### INSTALL/REMOVE RPMS FOLLOWING LIST
echo "08- Manage RPM packages"
while read -r line
do
	if [[ "$line" == add:* ]]
	then
		p=${line#add:}
		if ! check_pkg "$p"
		then
			echo -n "- - - Install package $p : "
			add_pkg "$p"
			check_cmd
		fi
	fi
	
	if [[ "$line" == del:* ]]
	then
		p=${line#del:}
		if check_pkg "$p"
		then
			echo -n "- - - Remove package $p : "
			del_pkg "$p"
			check_cmd
		fi
	fi
done < "$HERE/packages.list"

### INSTALL/REMOVE FLATPAK FOLLOWING LIST
echo "09- Manage FLATPAK packages"
while read -r line
do
	if [[ "$line" == add:* ]]
	then
		p=${line#add:}
		if ! check_flatpak "$p"
		then
			echo -n "- - - Install flatpak $p : "
			add_flatpak "$p"
			check_cmd
		fi
	fi
	
	if [[ "$line" == del:* ]]
	then
		p=${line#del:}
		if check_flatpak "$p"
		then
			echo -n "- - - Remove flatpak $p : "
			del_flatpak "$p"
			check_cmd
		fi
	fi
done < "$HERE/flatpak.list"