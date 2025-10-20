{
  config,
  pkgs,
  ...
}: let
  aliases = {
    # System Management
    syu = "cd /home/a42/nix/nixconfigs && nix flake update nixpkgs && sudo nixos-rebuild switch --flake .#nix42"; # Update nixpkgs and rebuild system
    hmu = "cd /home/a42/nix/nixconfigs && nix flake update home-manager && home-manager switch --flake .#a42k1"; # Update home-manager and switch
    syr = "sudo nixos-rebuild switch --flake /home/a42/nix/nixconfigs#nix42"; # Quick system rebuild without updating
    hmr = "home-manager switch --flake /home/a42/nix/nixconfigs#a42k1"; # Quick home-manager rebuild without updating

    # Navigation
    ll = "ls -l"; # List files in long format
    ".." = "cd .."; # Go up one directory

    # Garbage Collection
    gc-check = "nix-store --gc --print-dead"; # Preview what will be deleted (safe, no changes)
    gc-run = "sudo nix-collect-garbage -d";
    # System Information
    nix-size = "du -sh /nix/store"; # Check total Nix store disk usage
  };
in {
  #my configs
  programs.bash = {
    enable = true;
    shellAliases = aliases;
  };

  #SHELL
  programs.zsh = {
    enable = true;
    shellAliases = aliases;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
  programs.kitty = {
    enable = true;
  };
}
