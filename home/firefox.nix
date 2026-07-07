{ ... }:

{
  # firefox is the default browser on every host, vanilla unless the arkenfox toggle hardens it.
  # no policy here, so no "managed by your organization", the profile stays the user's own.
  programs.firefox.enable = true;
}
