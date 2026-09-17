#!/usr/bin/env bash

todo_color='\033[0;36m'
done_color='\033[0;32m'
clear_color='\033[0m'



paru -Pww
read -rp "Do you want to continue updating? [y/N] " answer
[[ "$answer" == "y" ]] || exit 0



echo -e "\n$todo_color updating mirrorlist...\n$clear_color"

sudo reflector -c Sweden -l 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose

echo -e "\n$done_color mirrorlist updated\n$clear_color"



echo -e "\n$todo_color updating packages with paru...\n$clear_color"

paru -Syu

echo -e "\n$done_color packages finished updating using paru\n$clear_color"



echo -e "\n$todo_color updating flatpak packages...\n$clear_color"

flatpak update -y

echo -e "\n$done_color flatpak packages updated\n$clear_color"



echo -e "\n$todo_color getting rid of unused flatpak packages...\n$clear_color"

flatpak uninstall --unused -y # get rid of unused flatpak packages

echo -e "\n$done_color flatpak orphans removed\n$clear_color"



# do the following only if pacman finds any orphans
orphans=$(pacman -Qdtq)
if [ -n "$orphans" ]; then
    
    echo -e "\n$todo_color getting rid of orpahs with pacman...\n$clear_color"

    sudo pacman -Rns $orphans

    echo -e "\n$done_color pacman orphans removed\n$clear_color"
fi



echo -e "\n$todo_color getting rid of old packages and unused cached package versions...\n$clear_color"

sudo paccache -rk2 # only keep the last 2 versions of each package
sudo paccache -ruk0 # remove cached versions of packages that aren't used

echo -e "\n$done_color removed unused pacman caches\n$clear_color"



echo -e "\n$todo_color getting rid of unused paru caches...\n$clear_color"

# doesn't delete the PKBUILD and other such files, as those are used to see diffs
sudo find ~/.cache/paru/clone -name '*.tar.gz' -delete
sudo find ~/.cache/paru/clone -name '*.pkg.tar.*' -delete
sudo find ~/.cache/paru/clone -name '*.deb' -delete # Debian files on Arch? Don't see how that makes sense, but an AUR package did do that so idk man

echo -e "\n$done_color finished cleaning unused paru caches\n$clear_color"



echo -e "\n$todo_color getting rid of old journalctl logs...\n$clear_color"

sudo journalctl --vacuum-time=10d # remove logs older than 10 days

echo -e "\n$done_color removed old journalctl logs\n$clear_color"



echo "done!"
