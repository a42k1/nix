{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  programs.niri.enable = true;
  environment.systemPackages = [
    pkgs.foot # required for the default Niri config
  ];
}
