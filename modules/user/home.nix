{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  dotfiles = "/home/nix/nix42/dotfiles";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  # Standard .config/directory
  configs = {
    Code = "vscode";
    niri = "niri";
    hypr = "hyprland";
  };
in {
  imports = [
    ./sh.nix
    ./hyprland/caelestia.nix
  ];
  home.username = "a42";
  home.homeDirectory = "/home/a42";
  home.packages = with pkgs; [
    hello
    wl-clipboard
    cider-2
  ];
  #Try xdg.configFile.
  xdg.configFile =
    builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.file = {
  };
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
