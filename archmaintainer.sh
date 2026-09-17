#!/usr/bin/env bash

todo_color='\033[0;36m'
done_color='\033[0;32m'



paru -Pww
read -rp "Do you want to continue updating? [y/n] " answer
[[ "$answer" == "y" ]] || exit 0



echo "\n$todo_color updating mirrorlist...\n"

sudo reflector -c Sweden -l 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose

echo "\n$done_color mirrorlist updated\n"



echo "\n$todo_color updating packages with paru...\n"

paru -Syu

echo "\n$done_color packages finished updating using paru\n"



echo "\n$todo_color updating flatpak packages...\n"

flatpak update -y

echo "\n$done_color flatpak packages updated\n"



echo "\n$todo_color getting rid of unused flatpak packages...\n"

flatpak uninstall --unused -y # get rid of unused flatpak packages

echo "\n$done_color flatpak orphans removed\n"



# do the following only if pacman finds any orphans
orphans=$(pacman -Qdtq)
if [ -n "$orphans" ]; then
    
    echo "\n$todo_color getting rid of orpahs with pacman...\n"

    sudo pacman -Rns $orphans

    echo "\n$done_color pacman orphans removed\n"
fi



echo "\n$todo_color getting rid of old packages and unused cached package versions...\n"

sudo paccache -rk2 # only keep the last 2 versions of each package
sudo paccache -ruk0 # remove cached versions of packages that aren't used

echo "\n$done_color removed unused pacman caches\n"



echo "\n$todo_color getting rid of unused paru caches...\n"

# doesn't delete the PKBUILD and other such files, as those are used to see diffs
sudo find ~/.cache/paru/clone -name '*.tar.gz' -delete
sudo find ~/.cache/paru/clone -name '*.pkg.tar.*' -delete
sudo find ~/.cache/paru/clone -name '*.deb' -delete # Debian files on Arch? Don't see how that makes sense, but an AUR package did do that so idk man

echo "\n$done_color finished cleaning unused paru caches\n"



echo "\n$todo_color getting rid of old journalctl logs...\n"

sudo journalctl --vacuum-time=10d # remove logs older than 10 days

echo "\n$done_color removed old journalctl logs\n"



echo "done!"
