#!/usr/bin/env bash

read -rp "make sure to look at https://archlinux.org/news/ in case anything has broken. Do you want to continue with the updating? [y/n] " answer
[[ "$answer" == "y" ]] || exit 0

# ---------- go through PKGBUILD diff of each AUR package that has an update

updates_available=false

mapfile -t aur_updates < <(yay -Qua | awk '{print $1}')

for pkg in "${aur_updates[@]}"; do

    updates_available=true
    
    echo
    read -rp "Update available for the AUR package $pkg. Press enter to see the PKGBUILD diff "

    tmpdir=$(mktemp -d)

    git clone --depth=1 "https://aur.archlinux.org/${pkg}.git" "$tmpdir" >/dev/null

    vimdiff "$HOME/.cache/yay/$pkg/PKGBUILD" "$tmpdir/PKGBUILD"

    rm -rf "$tmpdir"
done

if $updates_available; then
    echo
    read -rp "are all AUR packages safe to update? (If not then this script will terminate before updating anything) [y/n] " answer
    [[ "$answer" == "y" ]] || exit 0
fi

# ----------

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
echo "updating packages with yay..."
echo

yay -Syu --noconfirm # update system

echo
echo "------------------------------------"
echo "packages finished updating using yay"
echo "------------------------------------"
echo

echo
echo "updating flatpak packages..."
echo

flatpak update -y # update flatpak

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

    sudo pacman -Rns $orphans # remove orphaned packages

    echo
    echo "----------------------"
    echo "pacman orphans removed"
    echo "----------------------"
    echo
fi

echo
echo "getting rid of old packages and unused cached package versions..."
echo

sudo paccache -r # only keep the last 3 versions of each package
sudo paccache -ruk0 # remove cached versions of packages that aren't used

echo
echo "----------------------------"
echo "removed unused pacman caches"
echo "----------------------------"
echo

echo
echo "getting rid of unused yay caches, making sure to keep old PKGBUILDs for this script..."
echo

find ~/.cache/yay -name '*.pkg.tar.*' -delete # clears caches whilst avoiding removing old PKGBUILDs which are used in this script

echo
echo "-----------------------------------"
echo "finished cleaning unused yay caches"
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
