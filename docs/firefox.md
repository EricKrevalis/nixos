# firefox

my firefox is arkenfox-hardened and fully declarative. home-manager owns it and the profile
gets rebuilt from the repo every time, so i can wipe ~/.config/mozilla, run `nrs`, and it comes
back exactly the same. none of what's in the repo is sensitive (it's prefs and uBlock filter
settings, no passwords or cookies, those never lived here), so it can sit in a public repo fine.

heads up: the engine default browser is mullvad-browser, set in core, so a fork gets a safe
browser with zero effort. this hardened firefox is a per-host opt in, it lives in my host, not
in core. nobody forking the repo inherits my browsing setup unless they actually copy it.

## where the bits live

- `configs/firefox/user.js`, the arkenfox base, straight from their repo. i don't touch this by
  hand, `updater.sh` refreshes it (see bumping arkenfox below).
- `configs/firefox/user-overrides.js`, my prefs on top (quad9 dns, forcing gpu compositing,
  killing urlbar suggestions, ai off, clear-on-close). this is the file i actually edit for prefs.
- `configs/firefox/updater.sh`, arkenfox's own updater, vendored. only used to bump user.js.
- `configs/firefox/ublock-adminsettings.json`, my uBlock config, exported from the dashboard.
- `configs/firefox/natural_forest_green-1.0.xpi`, the theme. vendored because it's an obscure
  addon that could vanish from amo. uBlock isn't vendored, it's huge and never going away, so i
  pull it by hash instead.
- `hosts/desktop/home.nix`, where it's all wired up: the `programs.firefox` block with the
  profile, the prefs i let nix manage, and the policy that force-installs the extensions.

## why it's built this way

home-manager owns firefox instead of the system because only home-manager writes a per-profile
user.js. firefox 147+ uses ~/.config/mozilla (the xdg path) when ~/.mozilla doesn't exist, so
that's where the profile lands now. the "profile cannot be loaded, may be missing or
inaccessible" warning that dogged me for weeks came from firefox's new sqlite profile database
(the StoreID) disagreeing with a hand-copied profile. `browser.profiles.enabled = false` keeps
that whole new profile-db out of the picture, so the mismatch can't happen.

extensions go in through firefox's enterprise policy, pointed at pinned xpis. force-install
skips the "allow this extension" prompt and ignores signatures, so it's reproducible and works
offline. uBlock's settings come in over "managed storage" (the adminSettings key), which uBlock
reads on launch and lays over its own state. that's what makes my lists and rules just show up
on a fresh profile, no clicking.

locale is pinned to en-US so firefox stops nagging me to install the en-CA/en-GB language packs.

## putting this in your own repo

for me on another machine, or anyone who wants the hardened setup:

- copy `configs/firefox/` over.
- lift the `programs.firefox` block out of `hosts/desktop/home.nix` into your own host.
- swap `user-overrides.js` for your own prefs. keep the arkenfox base or refresh it, your call.
- replace `ublock-adminsettings.json` with your own (uBlock dashboard, backup to file, drop the
  timeStamp line).
- the extension ids and the pinned uBlock url/hash are mine, change them to yours.
- don't forget the default browser: core sends html/http/https to mullvad-browser, my host
  overrides that back to firefox. do the same override if you want firefox as default.

## changing my settings later (note to self)

the repo is the source of truth, the browser rebuilds from it. live tweaks don't survive a wipe,
and uBlock re-pulls its managed config on launch, so don't count on poking settings in the
browser and having them stick. if i change something and want to keep it, it goes back in the
repo. by case:

uBlock filters or rules:
- small thing (whitelist a site, add a list), just edit `ublock-adminsettings.json`, the shape
  is obvious.
- bigger thing, do it in the uBlock dashboard, then backup to file *before restarting* and drop
  the export over the json. delete the timeStamp line to keep the diff clean.
- then `nrs`.

arkenfox or firefox prefs:
- my own prefs (a `user_pref` line) live in `user-overrides.js`. that's the file for prefs.
- a few prefs i hand to nix directly (locale, theme, the profile-db toggle) are in the
  `programs.firefox` block in the host file, in `profiles.<name>.settings`.
- bumping arkenfox: `cd configs/firefox && ./updater.sh -n -d`. it pulls the latest arkenfox
  user.js over `user.js`. `-n` keeps it pristine (no overrides merged in, they stay their own
  file), `-d` skips the script self-update prompt. review `git diff user.js`, then `nrs`. don't
  run the updater against the live profile, nix owns that copy and would just overwrite it.

search engines, cookie exceptions, extensions:
- these aren't prefs, they live in binary/sqlite so they can't go in user.js. they're declared in
  the `programs.firefox` block in the host file: `search.engines` for the engine list and the
  hidden builtins, `policies.Permissions.Cookie.Allow` for the keep-logged-in sites, the policies
  block for the force-installed extensions. edit them there, not in user-overrides.js.

extensions:
- new uBlock version, grab the url and hash from the amo api
  (`https://addons.mozilla.org/api/v5/addons/addon/ublock-origin/`, fields current_version.file
  .url and .hash) and update the fetchurl in the host file.
- new addon, find its id (about:debugging, or its manifest), add it to ExtensionSettings as
  force_installed. pin by hash like uBlock, or vendor the xpi into `configs/firefox/` if it's
  something niche that might disappear.

start from scratch (the whole point of this):
- `rm -rf ~/.config/mozilla ~/.cache/mozilla`, then `nrs`. profile comes back identical.
- gotcha: if nothing else in the config changed, home-manager's activation unit doesn't re-run on
  that `nrs`, so a bare wipe-then-rebuild can come back empty. any real config change repopulates
  it fine. a new machine always rebuilds clean.
