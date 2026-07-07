{ settings, lib, ... }:

{
  # one block per git host from settings.sshIdentities, IdentitiesOnly so the agent never offers the wrong key.
  # the identities live in flake.nix common, this stays generic.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*".AddKeysToAgent = "yes";
    } // lib.mapAttrs (host: keyfile: {
      HostName = host;
      User = "git";
      IdentityFile = "~/.ssh/${keyfile}";
      IdentitiesOnly = true;
    }) settings.sshIdentities;
  };
}
