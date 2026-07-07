{ settings, ... }:

{
  time.timeZone = settings.timezone;

  i18n.defaultLocale = settings.locale;
  # english ui, international formats, no single english locale does both
  # categories split: ISO dates from en_DK, euro, metric and A4 from en_IE
  i18n.extraLocaleSettings = {
    LC_TIME        = "en_DK.UTF-8"; # YYYY-MM-DD, 24-hour, Monday-first weeks
    LC_MEASUREMENT = "en_IE.UTF-8"; # metric (km, kg)
    LC_PAPER       = "en_IE.UTF-8"; # A4
    LC_MONETARY    = "en_IE.UTF-8"; # euro, formatted as €1,234.56
  };
  # generate only the locales in use, keeps the closure small
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "${settings.locale}/UTF-8"
    "en_DK.UTF-8/UTF-8"
    "en_IE.UTF-8/UTF-8"
  ];
}
