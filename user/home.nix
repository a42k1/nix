{
  config,
  lib,
  pkgs,
  ...
}: let
  settings = "../settings";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  # Standard .config/directory
  configs = {
    vscode = "vscode";
  };
in {
  imports = [
    ./sh.nix
    # ../dotfiles/caelestia.nix
  ];
  nixpkgs.config.allowUnfree = true;
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
      source = create_symlink "${settings}/${subpath}";
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
