{
  config,
  lib,
  pkgs,
  ...
}: let
  dotfiles = "../dotfiles";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  # Standard .config/directory
  configs = {
    #   qtile = "qtile";
    #   nvim = "nvim";
    #   rofi = "rofi";
    #   alacritty = "alacritty";
    #   picom = "picom";
  };
in {
  imports = [
    ./sh.nix
  ];

  home.username = "a42k1";
  home.homeDirectory = "/home/a42k1";
  home.packages = with pkgs; [
    hello
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
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
