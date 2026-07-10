# archmaintainer
A simple bash script for keeping my Arch system up to date and in a good state. Note that I live in Sweden, so the reflector parameters reflect that.

I think flatpak packages have a chance of breaking after update. If that ever happens then run `flatpak repair`

dependencies:
- yay
- reflector (`sudo pacman -S reflector`)
- flatpak (`sudo pacman -S flatpak`)
- vim (`sudo pacman -S vim`)
- paccache (`sudo pacman -S pacman-contrib`)
