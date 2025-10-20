{
  config,
  pkgs,
  ...
}: {
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true; #For testing fps cpu gpu and temps
  programs.gamemode.enable = true; # Performance on games

  environment.systemPackages = with pkgs; [
    protonup-qt
    mangohud
    # Gaming performance layers
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
      rocmPackages.clr.icd
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
    ];
  };
}
