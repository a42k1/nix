# NixOS Gaming Setup Guide - AMD GPUs

Complete guide for setting up gaming on NixOS with AMD GPUs (RADV driver).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Hardware Requirements](#hardware-requirements)
- [Driver Verification](#driver-verification)
- [System Configuration](#system-configuration)
- [Performance Optimizations](#performance-optimizations)
- [Gaming Platforms](#gaming-platforms)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- NixOS with flakes enabled
- AMD GPU (GCN 3.0 or newer recommended)
- At least 16GB RAM for modern games
- SSD for game storage (recommended)

## Hardware Requirements

### Vulkan Requirements for vkd3d-proton

Your AMD GPU must support:

- Vulkan 1.3+
- At least 1,000,000 UpdateAfterBind descriptors
- Required extensions:
  - `VK_EXT_descriptor_indexing`
  - `VK_EXT_robustness2`
  - `VK_KHR_push_descriptor`
  - `VK_EXT_image_view_min_lod`
- Recommended extensions:
  - `VK_EXT_mutable_descriptor_type`
  - `VK_EXT_descriptor_buffer`

### Minimum Mesa Version

- Mesa 22.0+ (25.2.4+ recommended for best performance)

## Driver Verification

### Check Vulkan Support

```bash
# Install verification tools
nix-shell -p vulkan-tools glxinfo

# Check Vulkan version and device info
vulkaninfo --summary

# Verify Mesa/RADV version
glxinfo | grep -i "opengl version"
glxinfo | grep -i "mesa"

# Check for required extensions
vulkaninfo | grep -E "VK_EXT_descriptor_indexing|VK_EXT_robustness2|VK_KHR_push_descriptor|VK_EXT_image_view_min_lod|VK_EXT_mutable_descriptor_type|VK_EXT_descriptor_buffer"
```

### Expected Output

```
apiVersion         = 1.4.318+
driverVersion      = 25.2.4+
vendorID           = 0x1002 (AMD)
deviceType         = PHYSICAL_DEVICE_TYPE_DISCRETE_GPU or INTEGRATED_GPU
driverID           = DRIVER_ID_MESA_RADV
driverName         = radv
```

## System Configuration

### configuration.nix - Complete Gaming Setup

```nix
// filepath: /home/a42/Nix/.dotfiles/configuration.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel parameters for AMD GPU
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"  # Enable all AMD GPU features
  ];

  # Enable experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # User configuration
  users.users.YOUR_USERNAME = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "gamemode"    # Required for GameMode
      "video"       # GPU access
      "input"       # Controller access
    ];
  };

  # Graphics - AMD GPU Configuration
  services.xserver.videoDrivers = ["amdgpu"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Essential for Wine/Proton

    extraPackages = with pkgs; [
      # RADV (Mesa Vulkan driver)
      mesa.drivers

      # OpenCL support
      rocmPackages.clr.icd

      # Video acceleration
      vaapiVdpau
      libvdpau-va-gl
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa.drivers
    ];
  };

  # Gaming Programs
  programs.steam = {
    enable = true;

    # Proton-GE and other compatibility tools
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Steam with GameScope
    gamescopeSession.enable = true;

    # Extra compatibility tools
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

  # Other useful programs
  programs.firefox.enable = true;
  programs.git.enable = true;
  programs.direnv.enable = true;

  # Allow unfree packages (required for Steam, Discord, etc.)
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # === Wine & Compatibility ===
    wineWowPackages.stable     # Wine 32/64-bit
    wineWowPackages.staging    # Wine Staging (more features, less stable)
    winetricks                 # Wine helper scripts

    # === Gaming Platforms ===
    lutris                     # Multi-platform game launcher
    heroic                     # Epic Games & GOG launcher
    bottles                    # Wine prefix manager

    # === Performance Layers ===
    dxvk                       # DirectX 9/10/11 → Vulkan
    vkd3d-proton              # DirectX 12 → Vulkan (Valve's version)
    gamemode                   # CPU/GPU optimizations
    mangohud                   # FPS/performance overlay
    goverlay                   # GUI for MangoHUD configuration

    # === Proton Tools ===
    protonup-qt               # Manage Proton-GE versions
    protontricks              # Winetricks for Proton games
    steamtinkerlaunch         # Advanced Steam game tweaking

    # === Monitoring & Tools ===
    vulkan-tools              # vulkaninfo, vulkan-cube
    vulkan-validation-layers  # Vulkan debugging
    glxinfo                   # OpenGL info
    mesa-demos                # glxgears, etc.

    # === GPU Monitoring ===
    nvtopPackages.amd         # GPU monitoring for AMD
    radeontop                 # AMD GPU monitor

    # === Controllers ===
    linuxConsoleTools         # jstest, jscal
    antimicrox                # Controller mapping
    xboxdrv                   # Xbox controller driver

    # === Utilities ===
    wget
    curl
    fastfetch
    htop
  ];

  # System services
  services.xserver.enable = true;

  # Desktop environment (adjust to your preference)
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Audio (essential for gaming)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;  # Required for 32-bit games
    pulse.enable = true;
    jack.enable = true;        # Optional, for low-latency audio
  };

  # Networking
  networking.networkmanager.enable = true;

  # System state version
  system.stateVersion = "25.05";
}
```

### flake.nix - Flake Configuration

```nix
// filepath: /home/a42/Nix/.dotfiles/flake.nix
{
  description = "NixOS Gaming Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: nix-gaming for additional gaming tools
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      YOUR_HOSTNAME = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };

    homeConfigurations = {
      YOUR_USERNAME = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
      };
    };
  };
}
```

### home.nix - User Environment Configuration

```nix
// filepath: /home/a42/Nix/.dotfiles/home.nix
{ config, pkgs, ... }: {
  home.username = "YOUR_USERNAME";
  home.homeDirectory = "/home/YOUR_USERNAME";
  home.stateVersion = "25.05";

  # Gaming-related environment variables
  home.sessionVariables = {
    # AMD GPU optimizations
    RADV_PERFTEST = "gpl,nggc";           # Enable GPL & NGG culling
    AMD_VULKAN_ICD = "RADV";              # Force RADV driver

    # Wine/Proton optimizations
    WINEFSYNC = "1";                      # Enable fsync
    WINEESYNC = "1";                      # Enable esync
    DXVK_ASYNC = "1";                     # Async shader compilation
    DXVK_STATE_CACHE_PATH = "$HOME/.cache/dxvk";

    # MangoHUD configuration
    MANGOHUD = "1";
    MANGOHUD_CONFIG = "cpu_temp,gpu_temp,ram,vram,fps,frametime,position=top-right";

    # Performance
    mesa_glthread = "true";               # OpenGL multithreading
    __GL_THREADED_OPTIMIZATIONS = "1";
  };

  # Shell aliases for gaming
  programs.bash.shellAliases = {
    # Launch with GameMode + MangoHUD
    game = "mangohud gamemoderun";

    # Lutris with optimizations
    lutris-perf = "RADV_PERFTEST=gpl,nggc mangohud gamemoderun lutris";

    # Update gaming tools
    update-proton = "protonup-qt";
  };

  # MangoHUD configuration file
  home.file.".config/MangoHud/MangoHud.conf".text = ''
    # Performance metrics
    fps
    frametime
    cpu_temp
    gpu_temp
    ram
    vram

    # Position and style
    position=top-right
    font_size=24
    background_alpha=0.5

    # Toggle key
    toggle_hud=Shift_R+F12
  '';

  programs.home-manager.enable = true;
}
```

## Performance Optimizations

### 1. AMD GPU Performance Tuning

```bash
# Check current GPU performance level
cat /sys/class/drm/card0/device/power_dpm_force_performance_level

# Set to high performance (manual - resets on reboot)
echo "high" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level

# Set custom power profile
echo "1" | sudo tee /sys/class/drm/card0/device/pp_power_profile_mode
```

### 2. Persistent GPU Configuration

Add to `configuration.nix`:

```nix
# AMD GPU power management
systemd.services.amdgpu-performance = {
  description = "Set AMD GPU to high performance";
  wantedBy = [ "multi-user.target" ];
  after = [ "multi-user.target" ];

  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.bash}/bin/bash -c 'echo high > /sys/class/drm/card0/device/power_dpm_force_performance_level'";
  };
};
```

### 3. CPU Governor for Gaming

```nix
# Set CPU governor to performance
powerManagement.cpuFreqGovernor = "performance";

# Or use schedutil for balanced performance
# powerManagement.cpuFreqGovernor = "schedutil";
```

### 4. Kernel Parameters

```nix
boot.kernelParams = [
  # AMD GPU
  "amdgpu.ppfeaturemask=0xffffffff"

  # Reduce input latency
  "threadirqs"

  # Disable watchdog (can cause stuttering)
  "nowatchdog"
  "nmi_watchdog=0"

  # Memory management
  "vm.max_map_count=2147483642"  # Required for some games
];
```

### 5. System Limits

```nix
security.pam.loginLimits = [
  { domain = "@gamemode"; item = "nice"; type = "-"; value = "-10"; }
  { domain = "@gamemode"; item = "rtprio"; type = "-"; value = "99"; }
];
```

## Gaming Platforms

### Steam

Steam is already configured in `configuration.nix`. Additional setup:

1. **Enable Proton for all games:**

   - Steam → Settings → Compatibility
   - Enable "Steam Play for all other titles"
   - Select latest Proton version

2. **Install Proton-GE:**

   ```bash
   protonup-qt
   # Select GE-Proton version and install
   ```

3. **Per-game launch options:**
   ```
   RADV_PERFTEST=gpl,nggc mangohud gamemoderun %command%
   ```

### Lutris

1. **Configure Wine runners:**

   ```bash
   lutris
   # Preferences → Runners → Wine
   # Install wine-ge and other runners
   ```

2. **System options template:**

   - Enable DXVK
   - Enable VKD3D
   - Enable Esync/Fsync
   - Enable GameMode

3. **Environment variables:**
   ```
   RADV_PERFTEST=gpl,nggc
   DXVK_ASYNC=1
   MANGOHUD=1
   ```

### Heroic Games Launcher

```bash
heroic
# Settings → Other → Wine Version
# Install wine-ge-latest
```

Configure per-game settings:

- Enable DXVK
- Enable GameMode
- Add custom launch options

## Monitoring & Debugging

### MangoHUD In-Game Overlay

```bash
# Launch any game with MangoHUD
mangohud %command%

# Configure via GUI
goverlay
```

### GPU Monitoring

```bash
# Real-time AMD GPU stats
nvtop

# Alternative
radeontop

# Vulkan info
vulkaninfo --summary
```

### Wine/Proton Debugging

```bash
# Enable Wine debug output
WINEDEBUG=+all wine program.exe

# Proton debug logs
PROTON_LOG=1 %command%

# DXVK debug
DXVK_LOG_LEVEL=info %command%
```

### Performance Profiling

```bash
# Mesa performance overlay
VK_INSTANCE_LAYERS=VK_LAYER_MESA_overlay %command%

# Detailed Vulkan validation
VK_INSTANCE_LAYERS=VK_LAYER_KHRONOS_validation %command%
```

## Troubleshooting

### Issue: Low FPS or Stuttering

1. **Verify GPU is being used:**

   ```bash
   nvtop  # Should show GPU activity during gaming
   ```

2. **Check performance level:**

   ```bash
   cat /sys/class/drm/card0/device/power_dpm_force_performance_level
   # Should show "high" or "auto"
   ```

3. **Enable shader pre-caching:**
   - Steam: Settings → Shader Pre-Caching
   - Enable for Vulkan and OpenGL

### Issue: Game Won't Launch

1. **Check Proton logs:**

   ```bash
   # Steam Proton logs location
   ~/.local/share/Steam/steamapps/compatdata/APPID/pfx/
   ```

2. **Try different Proton versions:**

   - Proton Experimental
   - Proton-GE (latest)
   - Proton 8.0 or 9.0

3. **Verify dependencies:**
   ```bash
   # Check if 32-bit libraries are available
   nix-shell -p pkgsi686Linux.mesa
   ```

### Issue: No Audio in Games

1. **Verify PipeWire is running:**

   ```bash
   systemctl --user status pipewire
   ```

2. **Check game audio settings**

3. **Force PulseAudio compatibility:**
   ```bash
   PULSE_LATENCY_MSEC=60 %command%
   ```

### Issue: Controller Not Detected

1. **Test controller:**

   ```bash
   jstest /dev/input/js0
   ```

2. **Steam Input:**

   - Steam → Settings → Controller
   - Enable appropriate controller support

3. **Add user to input group (if not already):**
   ```bash
   sudo usermod -a -G input YOUR_USERNAME
   ```

### Issue: Crashes or Graphical Glitches

1. **Try different DXVK/VKD3D versions:**

   ```bash
   # Force specific DXVK version
   WINEPREFIX=~/.wine winetricks dxvk
   ```

2. **Disable RADV optimizations:**

   ```bash
   unset RADV_PERFTEST
   ```

3. **Check Mesa version:**
   ```bash
   glxinfo | grep "OpenGL version"
   # Update if below 23.0
   ```

## Benchmark & Testing

### Vulkan Tests

```bash
# Vulkan info
vulkaninfo

# Vulkan cube demo
vkcube

# Vulkan gears
vkcube-wayland  # If using Wayland
```

### Mesa Tests

```bash
# OpenGL gears
glxgears

# Advanced OpenGL test
glmark2
```

### Gaming Benchmarks

Install from Steam or Lutris:

- **3DMark** (via Proton)
- **Unigine Heaven**
- **Unigine Superposition**

## Additional Resources

- [ProtonDB](https://www.protondb.com/) - Game compatibility database
- [Lutris](https://lutris.net/) - Game installers and configs
- [RADV Mesa driver](https://docs.mesa3d.org/drivers/radv.html)
- [NixOS Gaming Wiki](https://nixos.wiki/wiki/Gaming)
- [r/linux_gaming](https://reddit.com/r/linux_gaming)

## Update Commands

```bash
# System update with nixpkgs
cd ~/.dotfiles && nix flake update nixpkgs && sudo nixos-rebuild switch --flake .

# Update all flake inputs
cd ~/.dotfiles && nix flake update && sudo nixos-rebuild switch --flake .

# Update Proton-GE
protonup-qt

# Clean old generations (free space)
sudo nix-collect-garbage -d
```

## Notes

- Always test games on ProtonDB before purchasing
- Keep Mesa/RADV updated for latest features and fixes
- Join the [Linux Gaming Discord](https://discord.gg/linuxgaming) for community support
- AMD GPUs generally have better Linux support than NVIDIA
- RADV (Mesa) is recommended over AMDVLK for gaming

---

**Last Updated:** October 2024  
**Tested on:** NixOS 25.05, Mesa 25.2.4, AMD Renoir (Ryzen 4000 series)
