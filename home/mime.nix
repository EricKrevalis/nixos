{ lib, pkgs, ... }:

{
  # call foot directly, the packaged nvim.desktop wants a default terminal
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "foot nvim %F";
    terminal = false;
    mimeType = [ "text/plain" ];
    categories = [ "Utility" "TextEditor" ];
  };

  # loop-mount an iso read-only via udisks (polkit, no sudo), then open it.
  # eject in thunar to unmount, udisks auto-clears the loop.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "iso-mount";
      runtimeInputs = with pkgs; [ udisks2 gnugrep gnused xdg-utils ];
      text = ''
        dev=$(udisksctl loop-setup -r -f "$1" | grep -o '/dev/loop[0-9]*')
        mnt=$(udisksctl mount -b "$dev" | sed -n 's/.* at \(.*\)\.$/\1/p')
        xdg-open "$mnt"
      '';
    })
  ];
  xdg.desktopEntries.iso-mount = {
    name = "Mount ISO";
    exec = "iso-mount %f";
    terminal = false;
    noDisplay = true; # a mime handler, not a launcher entry
    mimeType = [ "application/x-cd-image" "application/x-iso9660-image" ];
  };

  # ~/.config copy is a read-only store symlink thunar can't write to, defaults fall back to ~/.local/share
  xdg.configFile."mimeapps.list".enable = false;
  # a host can override the web handler to its own browser
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        forEach = desktop: types: lib.genAttrs types (_: desktop);
      in
        forEach "swayimg.desktop" [
          "image/png" "image/jpeg" "image/gif" "image/webp"
          "image/bmp" "image/tiff" "image/avif" "image/heif"
          # swayimg renders these too, else a zathura plugin claims them
          "image/svg+xml" "image/apng" "image/x-tga" "image/jxl"
          # swayimg previews font glyph sheets
          "font/ttf" "font/otf" "application/x-font-ttf"
        ]
        // forEach "org.pwmt.zathura.desktop" [
          "application/pdf" "application/epub+zip"
          "application/vnd.comicbook+zip" "application/x-cbz"
        ]
        // forEach "mpv.desktop" [
          "video/mp4" "video/x-matroska" "video/webm"
          "video/quicktime" "video/x-msvideo" "video/mpeg"
          "audio/mpeg" "audio/flac" "audio/x-wav"
          "audio/ogg" "audio/mp4" "audio/aac" "audio/opus" "audio/x-opus+ogg"
          "application/xspf+xml"
        ]
        // forEach "nvim.desktop" [
          # 0-byte files report x-zerosize
          "application/x-zerosize"
          "text/plain" "text/markdown" "application/json"
          "application/x-shellscript" "text/x-python" "text/x-csrc"
          # textual files with their own mime, they don't inherit text/plain so pin each
          "application/xml" "text/xml" "application/yaml" "text/x-yaml"
          "application/toml" "text/csv" "text/x-log" "text/rust" "text/x-rust"
          "application/x-desktop" "application/javascript" "application/sql"
          # subtitles and diffs are text, edit them in nvim
          "application/x-subrip" "text/vtt" "application/x-ass"
          "text/x-patch" "text/x-diff"
        ]
        // forEach "firefox.desktop" [
          "text/html" "x-scheme-handler/http" "x-scheme-handler/https"
        ]
        // forEach "xarchiver.desktop" [
          # without these, zathura's comicbook plugin grabs zip/tar/7z/rar and can't extract
          "application/zip" "application/x-tar" "application/x-compressed-tar"
          "application/gzip" "application/x-bzip2" "application/x-xz"
          "application/zstd" "application/x-7z-compressed"
          "application/x-rar" "application/vnd.rar"
        ]
        // {
          # folders to thunar, else zathura's comicbook plugin claims inode/directory
          "inode/directory" = "thunar.desktop";
          # terminal for gui-launched Terminal=true apps (nvim), unset by default
          "x-scheme-handler/terminal" = "foot.desktop";
          # double-click an iso to loop-mount it, see the iso-mount handler above
          "application/x-cd-image" = "iso-mount.desktop";
          "application/x-iso9660-image" = "iso-mount.desktop";
        };
  };
}
