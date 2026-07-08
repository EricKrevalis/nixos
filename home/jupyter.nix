{ pkgs, ... }:

let
  # jupyterlab, its default kernel, and the analysis libs. replaces a per-notebook venv
  jupyterEnv =
    let
      py = pkgs.python3.withPackages (ps: with ps; [
        jupyterlab
        ipykernel
        numpy
        pandas
        matplotlib
      ]);
      lab = pkgs.python3Packages.jupyterlab;
    in
    # nixpkgs jupyterlab wraps its bins with a literal unexpanded JUPYTERLAB_DIR='$out/...' (nixpkgs#423927).
    # it resolves against cwd, so the lab assets go missing and lab refuses to start.
    # the export is unconditional, no session var or --app-dir survives it.
    # re-wrap the three lab bins onto the real entry with the correct dir, avoids a source rebuild.
    pkgs.symlinkJoin {
      name = "jupyter-env";
      paths = [ py ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for b in jupyter-lab jupyter-labextension jupyter-labhub; do
          rm -f $out/bin/$b
          makeWrapper ${lab}/bin/.$b-wrapped $out/bin/$b \
            --set JUPYTERLAB_DIR ${lab}/share/jupyter/lab \
            --prefix PATH : ${py}/bin
        done
      '';
    };

  # run lab headless and open it in a throwaway firefox window, off the main profile.
  # closing that window shuts the server down, so a forgotten server can't linger.
  # optional arg: a notebook to open straight away. leaves the terminal free
  jlab = pkgs.writeShellScriptBin "jlab" ''
    set -uo pipefail

    # re-exec detached in a new session so the terminal is freed and Ctrl-C or closing it can't reach the server.
    # the copy below does the real work
    if [ "''${JLAB_BG:-}" != 1 ]; then
      JLAB_BG=1 setsid "$0" "$@" >/dev/null 2>&1 </dev/null &
      exit 0
    fi

    log=$(mktemp)
    profile="''${XDG_DATA_HOME:-$HOME/.local/share}/firefox-previews/jlab"
    mkdir -p "$profile"

    target="/lab"
    if [ -n "''${1:-}" ]; then
      cd "$(dirname "$1")" || exit 1
      target="/lab/tree/$(basename "$1")"
    fi

    ${jupyterEnv}/bin/jupyter lab --no-browser >"$log" 2>&1 &
    server=$!

    url=""
    for _ in $(seq 1 100); do
      url=$(grep -om1 'http://localhost:[0-9]*/lab?token=[A-Za-z0-9]*' "$log") && [ -n "$url" ] && break
      kill -0 "$server" 2>/dev/null || break
      sleep 0.1
    done
    if [ -z "$url" ]; then
      echo "jupyter lab did not start:" >&2; cat "$log" >&2
      kill "$server" 2>/dev/null; rm -f "$log"; exit 1
    fi

    port=$(echo "$url" | sed -n 's#.*localhost:\([0-9]*\)/.*#\1#p')
    token=''${url##*token=}
    # dedicated instance so closing the window exits firefox, the script waits on it
    firefox --no-remote --profile "$profile" --private-window \
      "http://localhost:$port$target?token=$token" >/dev/null 2>&1 || true

    kill "$server" 2>/dev/null || true
    wait "$server" 2>/dev/null || true
    rm -f "$log"
  '';
in

{
  # packaged jupyterlab.desktop runs jupyter-lab in a terminal, this runs jlab instead
  xdg.desktopEntries.jupyterlab = {
    name = "JupyterLab";
    genericName = "Run JupyterLab";
    icon = "jupyterlab";
    exec = "jlab %f";
    terminal = false;
    mimeType = [ "application/x-ipynb+json" ];
    categories = [ "Development" "Education" ];
  };

  # default kernel, discovered through this spec
  xdg.dataFile."jupyter/kernels/python3/kernel.json".text = builtins.toJSON {
    argv = [ "${jupyterEnv}/bin/python3" "-m" "ipykernel_launcher" "-f" "{connection_file}" ];
    display_name = "python3 (default)";
    language = "python";
  };

  # lab ui seeded declaratively: dark theme, atkinson mono everywhere.
  # the three sizes are the knobs, change them here and rebuild.
  # read-only symlink, so this plugin's settings can't be changed from the gui, other plugins stay writable.
  home.file.".jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings".text =
    let font = "Atkinson Hyperlegible Mono";
    in builtins.toJSON {
      theme = "JupyterLab Dark";
      overrides = {
        "code-font-family" = font;     # cell editors
        "code-font-size" = "14px";
        "content-font-family" = font;  # rendered markdown and text output
        "content-font-size1" = "13px";
        "ui-font-family" = font;       # menus, sidebar, tabs
        "ui-font-size1" = "12px";
      };
    };

  home.packages = [
    jupyterEnv # jupyter and python on PATH, for kernels and pip workflows
    jlab       # headless lab in a throwaway firefox window, dies with the window
  ];
}
