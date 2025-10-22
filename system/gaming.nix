{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
    "threadirqs"
  ];
  powerManagement.cpuFreqGovernor = "performance";

  programs.steam = {
    enable = true;

    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };

      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    wineWowPackages.staging
    winetricks
    lutris
    protonup-qt
    mangohud

    dxvk
    vkd3d-proton

    # Vulkan debugging and info tools
    vulkan-tools # Provides vulkaninfo, vulkan-cube
    vulkan-validation-layers
    glxinfo # For Mesa version info
  ];
  # Graphics - GPU (AMD)
  services.xserver.videoDrivers = ["amdgpu"];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      rocmPackages.clr.icd
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
    ];
  };
}
