{ ... }:

{
  hardware.bluetooth.enable = true; # powers on at boot so paired audio devices reconnect

  # audio, PipeWire instead of PulseAudio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
