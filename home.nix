{
  config,
  pkgs,
  ...
}: let
  aliases = {
    # System Management
    syu = "cd /home/a42/Nix/.dotfiles && nix flake update nixpkgs && sudo nixos-rebuild switch --flake ."; # Update nixpkgs and rebuild system
    hmu = "cd /home/a42/Nix/.dotfiles && nix flake update home-manager && home-manager switch --flake ."; # Update home-manager and switch
    syr = "sudo nixos-rebuild switch --flake /home/a42/Nix/.dotfiles"; # Quick system rebuild without updating
    hmr = "home-manager switch --flake /home/a42/Nix/.dotfiles"; # Quick home-manager rebuild without updating

    # Navigation
    ll = "ls -l"; # List files in long format
    ".." = "cd .."; # Go up one directory

    # Garbage Collection
    gc-check = "nix-store --gc --print-dead"; # Preview what will be deleted (safe, no changes)
    gc-run = "sudo nix-collect-garbage -d"; # Delete old generations and collect garbage (recommended for regular cleanup)
    gc-older = "sudo nix-collect-garbage --delete-older-than 7d"; # Delete generations older than 7 days (keeps recent changes)

    # System Information
    nix-size = "du -sh /nix/store"; # Check total Nix store disk usage
    list-gens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system"; # List all system generations with dates
  };
in {
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "a42k1";
  home.homeDirectory = "/home/a42k1";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/a42k1/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
