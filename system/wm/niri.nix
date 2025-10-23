{
  configs,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.overlays = [niri.overlays.niri];
  environment.systemPackages = with pkgs; [
    niri-stable
  ];
}
