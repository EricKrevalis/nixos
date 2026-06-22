{ settings, lib, pkgs, ... }:
let
  mod = "Mod4";
in
# home-side user apps for the polished desktop layer, gated like core/modules/polish.nix.
lib.mkIf settings.polish {
  # clipboard history. the cliphist package is system-side polish, this wires the watcher and picker.
  wayland.windowManager.sway.config = {
    startup = [
      # store clipboard history, skipping file-manager copies (they land as a useless path/uri)
      { command = "wl-paste --watch sh -c 'wl-paste --list-types | grep -q gnome-copied-files || cliphist store'"; }
    ];
    # mkOptionDefault so this merges into base's bindings instead of replacing the whole set
    keybindings = lib.mkOptionDefault {
      "${mod}+c" = "exec bash -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'";
    };
  };

  home.packages = [
    # wrapped to fix chromium shared-memory crash on NixOS + NVIDIA
    (pkgs.symlinkJoin {
      name = "tidal-hifi";
      paths = [ pkgs.tidal-hifi ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/tidal-hifi \
          --add-flags "--disable-dev-shm-usage --disable-gpu-sandbox"
      '';
    })
  ];
}
