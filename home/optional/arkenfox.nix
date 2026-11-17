{ settings, lib, pkgs, ... }:

# arkenfox hardening, enabled by the arkenfox toggle
# firefox is always installed, this only adds the hardened profile: user.js, ublock, theme
# the manual non-nix setup guide is the README in configs/firefox, alongside these files
let
  # dropped into the profile, not policy, so no "managed by your organization", settings stay editable in the ui
  # a profile install checks signatures, so the signed amo xpis go in untouched, repacking would void them
  ublock = pkgs.fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4814095/ublock_origin-1.71.0.xpi";
    sha256 = "47f788a1fc2c014830b30bb0ef9588615701b98c5265fb19b8cf4ba779849feb";
  };
  ublockId = "uBlock0@raymondhill.net";
  theme = ../../configs/firefox/natural_forest_green-1.0.xpi; # amo file/3903186, v1.0
  themeId = "{054dd025-3fbd-45ab-a3d9-a22cecbbdd07}";

  # home-manager fills <profile>/extensions from each package's share/mozilla tree
  # firefox keys that dir by its own app id, the xpi inside is named by the addon id
  sideload = name: id: xpi: pkgs.runCommand name { } ''
    d="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$d"
    cp ${xpi} "$d/${id}.xpi"
  '';
in

lib.mkIf settings.arkenfox {
  # the sideloaded theme owns the firefox look, stylix stays out
  stylix.targets.firefox.enable = false;

  # enable lives in firefox.nix, firefox is always installed, this only adds the profile
  programs.firefox = {
    profiles.arkenfox-tinkered = {
      isDefault = true;
      settings = {
        "browser.profiles.enabled" = false;   # off, the profile manager's database desyncs and flags the profile inaccessible
        "intl.locale.requested" = "en-US";    # built-in ui locale, no langpack install prompt
        "extensions.activeThemeID" = themeId; # select the forest green theme once it's installed
        "extensions.autoDisableScopes" = 0;   # auto-enable the profile-installed extensions, no approval prompt

        # default fonts, only backs pages that don't set their own
        "font.name.sans-serif.x-western" = "Atkinson Hyperlegible Next";
        "font.name.serif.x-western"      = "Atkinson Hyperlegible Next";
        "font.name.monospace.x-western"  = "Atkinson Hyperlegible Mono";
      };
      # arkenfox base then the overrides, the same order arkenfox's own updater uses
      extraConfig = builtins.readFile ../../configs/firefox/user.js
                  + builtins.readFile ../../configs/firefox/user-overrides.js;
      # ublock's filters aren't seeded here, no nix-side way to do it without enforcing them each launch
      # ublock-adminsettings.json imported once by hand, ublock keeps them after that
      extensions.packages = [
        (sideload "ublock-origin" ublockId ublock)
        (sideload "natural-forest-green-theme" themeId theme)
      ];
      # force=true lets home-manager overwrite the search db firefox rewrites each launch.
      # hiding a builtin actually drops it, the settings ui only grays out its remove button.
      # no aliases on the engines, no urlbar search shortcuts
      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
        order = [ "ddg" "startpage" "qwant" "mojeek" "brave" ];
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
            icon = "https://brave.com/favicon.ico"; # search.brave.com/favicon.ico 404s, brave.com has the real icon
          };
          google.metaData.hidden = true;
          bing.metaData.hidden = true;
          ebay.metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          wikipedia.metaData.hidden = true;
          ecosia.metaData.hidden = true;	# morally nice, but not privacy focused
          perplexity.metaData.hidden = true;
          # builtin qwant sends client=brz-moz, qwant 403s that now
          # full override here, not metaData.hidden, key stays "qwant" for default/order above
          qwant = {
            name = "Qwant";
            urls = [{ template = "https://www.qwant.com/?q={searchTerms}&t=web"; }];
            icon = "https://www.qwant.com/favicon.ico";
          };
        };
      };
    };
  };
}
