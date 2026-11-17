{ ... }:

# rootless podman, no daemon. isNormalUser allocates the subuid/subgid ranges rootless needs
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # docker command maps to podman
  };

  # short names like user/image resolve on docker hub, same as docker.
  # replaces the module default, whose bare [[registry]] entries set nothing
  virtualisation.containers.registries.settings.unqualified-search-registries = [ "docker.io" ];
}
