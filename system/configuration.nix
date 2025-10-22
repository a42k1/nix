{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./gaming.nix
  ];
  options = {
    my.arbritary.option = lib.mkOption {
      type = lib.types.str;
      default = "stuff";
    };
  };
  config = {
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # shell
    environment.shells = with pkgs; [zsh];
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    networking.hostName = "nix42";
    networking.networkmanager.enable = true;
    time.timeZone = "America/Fortaleza";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 50;
    };
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.a42 = {
      isNormalUser = true;
      description = "Gustavo";
      extraGroups = ["networkmanager" "wheel" "gamemode" "video" "input"];
    };

    # Enable Applications
    programs.firefox.enable = true;
    programs.git.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      wget
      vscode
      tree
      discord
      qownnotes
      fastfetch
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    # A42 home partition
    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/ef394725-6efc-4a3c-8438-a7758b4101a2";
      fsType = "ext4";
      options = ["defaults" "nofail"];
    };

    system.autoUpgrade = {
      enable = true;
      flake = "path:/home/nix/";
      flags = [
        "--update-input"
        "nixpkgs"
        "--update-input"
        "home-manager"
        "--commit-lock-file"
      ];
      dates = "daily";
      allowReboot = false;
      persistent = true;
    };
    # Automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 6d";
    };

    # Optimize nix store automatically
    nix.optimise = {
      automatic = true;
      dates = ["weekly"];
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?
    nix.settings.experimental-features = ["nix-command" "flakes"];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
