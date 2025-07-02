# nixos-files
files for my nixos-installation. DO NOT USE WORK IN PROGRESS!

BTW If you for some reason use this at this point. Use your own hardware configuration, bc this hardware configuration is for my laptop I'm testing on so this would (maybe) break your installation if you use it.

If you want to change your username. Change it in flake.nix and in configuration.nix

To make wlogout (and maybe other programs in the future work) put your nixos-files in your home folder so ~/nixos-files

**Distrobox**

I added some programs via distrobox like the thorium-browser. I will try to keep it that my system keeps working without needing the distrobox programs, but if you want the full setup you can use the arch-snapshot.tar.xz file (that is split up in distrobox/arch-snapshot. I will try to keep it up to date.

To install it:
- Go to correct directory
`cd ~/nixos-files/distrobox/arch-snapshot`

- Join the files together
`cat arch-part-* > arch-snapshot.tar.xz`

- Decompress xz file
`unxz arch-snapshot.tar.xz`

- Load into podman
`podman load -i arch-snapshot.tar`

- Create a new distrobox
`distrobox create --name arch --image arch-snapshot`

- Enter distrobox to set it up
`distrobox enter arch`
