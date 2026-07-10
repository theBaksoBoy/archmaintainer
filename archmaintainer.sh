#!/usr/bin/env sh

echo "updating mirrorlist before doing package updates"
echo
sudo reflector -c Sweden,Germany,Denmark,Finland -l 30 --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose # update mirror list

echo
echo "------------------"
echo "updated mirrorlist"
echo "------------------"
echo

# ---------- go through PKGBUILD diff of each AUR package that has an update

updates_available=0

mapfile -t aur_updates < <(yay -Qua | awk '{print $1}')

for pkg in "${aur_updates[@]}"; do

    updates_available=1
    
    echo
    read -rp "Update available for $pkg. Press enter to see the PKGBUILD diff "

    tmpdir=$(mktemp -d)

    git clone --depth=1 "https://aur.archlinux.org/${pkg}.git" "$tmpdir" >/dev/null

    vimdiff "$HOME/.cache/yay/$pkg/PKGBUILD" "$tmpdir/PKGBUILD"

    rm -rf "$tmpdir"
done

if [[ $updates_available == 1 ]]; then
    echo
    read -rp "are all AUR packages safe to update? (If not then this script will terminate before updating anything) [y/n] " answer
    [[ "$answer" == "y" ]] || exit 0
fi

# ----------



yay -Syu --noconfirm # update system

echo
echo "------------------------------------"
echo "packages finished updating using yay"
echo "------------------------------------"
echo

flatpak update -y # update flatpak
flatpak uninstall --unused -y # get rid of unused flatpak packages

echo
echo "------------------------"
echo "flatpak packages updated"
echo "------------------------"
echo

orphans=$(pacman -Qdtq)
if [ -n "$orphans" ]; then
    sudo pacman -Rns $orphans # remove orphaned packages

    echo
    echo "----------------------"
    echo "pacman orphans removed"
    echo "----------------------"
    echo
fi

sudo paccache -r # only keep the last 3 versions of each package
sudo paccache -ruk0 # remove cached versions of packages that aren't used

echo
echo "----------------------------"
echo "removed unused pacman caches"
echo "----------------------------"
echo

find ~/.cache/yay -name '*.pkg.tar.*' -delete # clears caches whilst avoiding removing old PKGBUILDs which are used in this script

echo
echo "-----------------------------------"
echo "finished cleaning unused yay caches"
echo "-----------------------------------"
echo

# reinstall all flatpak apps as removing orphaned packages can mess up flatpak stuff sometimes
flatpak_apps=$(flatpak list --app --columns=application)
if [ -n "$flatpak_apps" ]; then
    for app in $flatpak_apps; do
        run_command "flatpak install --reinstall -y $app"
    done
fi

echo
echo "-----------------------------------------------------------------"
echo "finished reinstalling flatpak packages to avoid dependency issues"
echo "-----------------------------------------------------------------"
echo

sudo journalctl --vacuum-time=10d # remove logs older than 10 days

echo
echo "---------------------------"
echo "removed old journalctl logs"
echo "---------------------------"
echo

echo "done!"
