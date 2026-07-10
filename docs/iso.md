# building a custom installer iso

not needed for most machines, the stock nixos iso is enough, see `docs/bootstrap.md`.
only worth it when the hardware needs a driver the stock kernel doesn't have, no network on the stock iso means no way to even clone the repo.
surface is the example: linux-surface's kernel and wifi driver had to be baked in before install could start.

## steps

1. add a temporary output to `flake.nix`, under `nixosConfigurations`:
   ```nix
   <name>-installer = lib.nixosSystem {
     system = "x86_64-linux";
     modules = [
       "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
       <hardware module>
     ];
   };
   ```
   for surface that hardware module was `nixos-hardware.nixosModules.microsoft-surface-pro-intel`, same one `mkHost` already appends for the `surface` host.
2. build it:
   ```bash
   nix build .#nixosConfigurations.<name>-installer.config.system.build.isoImage
   ```
3. the image lands at `result/iso/*.iso`, write it to a usb stick (`dd`, ventoy, etcher, whatever's on hand).
4. install from that stick, then follow the normal steps in `docs/bootstrap.md` from "redoing this on a fresh machine".
5. remove the temporary output from `flake.nix` again once the install is done, it's a bootstrap tool, not something that needs to live in the repo permanently.

## surface specifically

this exact block lived in `flake.nix` as `surface-installer` during the first surface install, then got pulled back out once the machine was up.
if surface ever needs a reinstall, add it back with the same hardware module.
