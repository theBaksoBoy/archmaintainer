#!/usr/bin/env bash

read -rp "make sure to look at https://archlinux.org/news/ in case anything has broken. Do you want to continue with the updating? [y/n] " answer
[[ "$answer" == "y" ]] || exit 0

echo
echo "updating mirrorlist before doing package updates..."
echo

sudo reflector -c Sweden,Germany,Denmark,Finland -l 30 --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose # update mirror list

echo
echo "------------------"
echo "mirrorlist updated"
echo "------------------"
echo

echo
echo "updating packages with paru..."
echo

paru -Syu

echo
echo "------------------------------------"
echo "packages finished updating using paru"
echo "------------------------------------"
echo

echo
echo "updating flatpak packages..."
echo

flatpak update -y

echo
echo "------------------------"
echo "flatpak packages updated"
echo "------------------------"
echo

echo
echo "getting rid of unused flatpak packages..."
echo

flatpak uninstall --unused -y # get rid of unused flatpak packages

orphans=$(pacman -Qdtq)
if [ -n "$orphans" ]; then
    
    echo
    echo "getting rid of orpahs with pacman..."
    echo

    sudo pacman -Rns $orphans

    echo
    echo "----------------------"
    echo "pacman orphans removed"
    echo "----------------------"
    echo
fi

echo
echo "getting rid of old packages and unused cached package versions..."
echo

sudo paccache -rk2 # only keep the last 2 versions of each package
sudo paccache -ruk0 # remove cached versions of packages that aren't used

echo
echo "----------------------------"
echo "removed unused pacman caches"
echo "----------------------------"
echo

echo
echo "getting rid of unused paru caches..."
echo

# doesn't delete the PKBUILD and other such files, as those are used to see diffs
sudo find ~/.cache/paru/clone -name '*.tar.gz' -delete
sudo find ~/.cache/paru/clone -name '*.pkg.tar.*' -delete
sudo find ~/.cache/paru/clone -name '*.deb' -delete # Debian files on Arch? Don't see how that makes sense, but an AUR package did do that so idk man

echo
echo "-----------------------------------"
echo "finished cleaning unused paru caches"
echo "-----------------------------------"
echo

echo
echo "getting rid of old journalctl logs..."
echo

sudo journalctl --vacuum-time=10d # remove logs older than 10 days

echo
echo "---------------------------"
echo "removed old journalctl logs"
echo "---------------------------"
echo

echo "done!"
