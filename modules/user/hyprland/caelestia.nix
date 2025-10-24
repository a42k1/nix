{
  config,
  pkgs,
  inputs,
  ...
}: rec {
  home.packages = [
    inputs.caelestia-shell.packages.${pkgs.system}.default
  ];
}
