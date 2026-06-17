{ lib, pkgs, ... }:

let
  # both force-installed by policy, which exempts them from signature checks and skips
  # the install prompt. ublock is hash-pinned from amo (mainstream, always there). the
  # theme is vendored in the repo since this niche one could vanish from amo.
  ublock = pkgs.fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4814095/ublock_origin-1.71.0.xpi";
    sha256 = "47f788a1fc2c014830b30bb0ef9588615701b98c5265fb19b8cf4ba779849feb";
  };
  forestGreen = ../../configs/firefox/natural_forest_green-1.0.xpi; # amo file/3903186, v1.0
  ublockId = "uBlock0@raymondhill.net";
  themeId = "{054dd025-3fbd-45ab-a3d9-a22cecbbdd07}";
in

{
  # HDMI-A-1 = Zowie XL    (sn GAG02576SL0)    left,   60Hz
  # DP-1     = Zowie XL    (sn EBM2M00765SL0)  middle, 240Hz (main)
  # DP-2     = BenQ RL2455 (sn S4D05178SL0)    right,  60Hz
  wayland.windowManager.sway.extraConfig = ''
    output HDMI-A-1 mode 1920x1080@60Hz position 0,0
    output DP-1 mode 1920x1080@240Hz position 1920,0
    output DP-2 mode 1920x1080@60Hz position 3840,0
    workspace 1 output DP-1
    workspace 2 output DP-1
    workspace 3 output DP-1
    workspace 4 output DP-1
    workspace 5 output HDMI-A-1
    workspace 6 output HDMI-A-1
    workspace 7 output HDMI-A-1
    workspace 8 output DP-2
    workspace 9 output DP-2
    workspace 10 output DP-2
    workspace number 1
  '';

  # pin notifications to the main monitor
  services.mako.settings.output = "DP-1";

  # generic audio drop-in only, device-specific ones are in configs/wireplumber
  xdg.configFile."wireplumber/wireplumber.conf.d".source = ../../configs/wireplumber;

  # pipewire daemon drop-in, clock rate and resampler quality
  xdg.configFile."pipewire/pipewire.conf.d/99-sample-rate.conf".source = ../../configs/pipewire/99-sample-rate.conf;

  # sync the goxlr profile, mic profile and presets from the repo on every rebuild
  # copy not symlink, a read-only store link blocks the daemon writing this dir
  # repo wins each build, tweak it in the UI then copy back here to keep a change
  home.activation.syncGoxlr = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    src=${../../configs/goxlr}
    data="$HOME/.local/share/goxlr-utility"
    cfg="$HOME/.config/goxlr-utility"
    run mkdir -p "$data" "$cfg"
    run cp -r --no-preserve=mode "$src/profiles" "$src/mic-profiles" "$src/presets" "$data/"
    run cp --no-preserve=mode "$src/settings.json" "$cfg/settings.json"
    # hot-load the refreshed profiles by name, no-ops if the daemon is not up yet
    run ${pkgs.goxlr-utility}/bin/goxlr-client profiles device load Default || true
    run ${pkgs.goxlr-utility}/bin/goxlr-client profiles microphone load DEFAULT || true
  '';

  # firefox: my arkenfox-hardened profile. home-manager owns the package so it can write
  # the profile's user.js and inject the policy that force-installs ublock and the theme.
  programs.firefox = {
    enable = true;
    profiles.arkenfox-tinkered = {
      isDefault = true;
      settings = {
        "browser.profiles.enabled" = false;   # off, ff's new profile db desyncs and flags the profile inaccessible
        "intl.locale.requested" = "en-US";    # built-in ui locale, no langpack install prompt
        "extensions.activeThemeID" = themeId; # apply the forest green theme
      };
      # arkenfox base then my overrides, the same order arkenfox's own updater uses
      extraConfig = builtins.readFile ../../configs/firefox/user.js
                  + builtins.readFile ../../configs/firefox/user-overrides.js;
      # force=true lets home-manager overwrite the search db firefox rewrites each launch.
      # hiding a builtin actually drops it, the settings ui only grays out its remove button.
      # no aliases on my engines, i don't want urlbar search shortcuts.
      search = {
        force = true;
        default = "qwant";
        privateDefault = "qwant";
        order = [ "qwant" "startpage" "mojeek" "ddg" "brave" ];
        engines = {
          startpage = {
            name = "Startpage";
            urls = [{ template = "https://www.startpage.com/sp/search?query={searchTerms}"; }];
            icon = "https://www.startpage.com/favicon.ico";
          };
          mojeek = {
            name = "Mojeek";
            urls = [{ template = "https://www.mojeek.com/search?q={searchTerms}"; }];
            icon = "https://www.mojeek.com/favicon.ico";
          };
          brave = {
            name = "Brave Search";
            urls = [{ template = "https://search.brave.com/search?q={searchTerms}"; }];
            icon = "https://search.brave.com/favicon.ico";
          };
          google.metaData.hidden = true;
          bing.metaData.hidden = true;
          ebay.metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          wikipedia.metaData.hidden = true;
          ecosia.metaData.hidden = true;	# morally nice, but not privacy focused
          qwant.metaData.hidden = false;	# privacy focused EU. ES region bound
          perplexity.metaData.hidden = true;
        };
      };
    };
    policies = {
      ExtensionSettings = {
        ${ublockId} = {
          installation_mode = "force_installed";
          install_url = "file://${ublock}";
        };
        ${themeId} = {
          installation_mode = "force_installed";
          install_url = "file://${forestGreen}";
        };
      };
      # ublock reads adminSettings from managed storage at launch and overwrites its own
      # state, so this repo json is the single source of truth for filters and rules
      "3rdparty".Extensions.${ublockId}.adminSettings =
        builtins.fromJSON (builtins.readFile ../../configs/firefox/ublock-adminsettings.json);
    };
  };

  # web links open in my firefox, overriding the engine's mullvad-browser default
  xdg.mimeApps.defaultApplications = {
    "text/html" = lib.mkForce "firefox.desktop";
    "x-scheme-handler/http" = lib.mkForce "firefox.desktop";
    "x-scheme-handler/https" = lib.mkForce "firefox.desktop";
  };
}
