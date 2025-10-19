# NixOS Gaming Setup Guide - NVIDIA GPUs

Complete guide for setting up gaming on NixOS with NVIDIA GPUs (proprietary driver).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Hardware Requirements](#hardware-requirements)
- [Driver Installation](#driver-installation)
- [Driver Verification](#driver-verification)
- [System Configuration](#system-configuration)
- [Performance Optimizations](#performance-optimizations)
- [Gaming Platforms](#gaming-platforms)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- NixOS with flakes enabled
- NVIDIA GPU (GTX 900 series or newer recommended)
- At least 16GB RAM for modern games
- SSD for game storage (recommended)

## Hardware Requirements

### Vulkan Requirements for vkd3d-proton

Your NVIDIA GPU must support:

- Vulkan 1.3+
- Driver version 535+ (Vulkan beta drivers recommended)
- At least 1,000,000 UpdateAfterBind descriptors
- Required extensions:
  - `VK_EXT_descriptor_indexing`
  - `VK_EXT_robustness2`
  - `VK_KHR_push_descriptor`
  - `VK_EXT_image_view_min_lod`
- Recommended extensions:
  - `VK_EXT_mutable_descriptor_type`
  - `VK_EXT_descriptor_buffer`

### Minimum Driver Version

- Stable: 535+ (550+ recommended)
- Beta/Vulkan Beta: Always prefer latest for gaming

## Driver Installation

### Option 1: Stable Driver (Recommended for Most Users)

```nix
// filepath: /home/a42/Nix/.dotfiles/configuration.nix
{
  config,
  pkgs,
  ...
}: {
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Use open source kernel module (Turing+ GPUs)
    open = false;  # Set to true for RTX 20xx+ (Turing, Ampere, Ada)

    # Enable NVIDIA settings menu
    nvidiaSettings = true;

    # Use latest stable driver
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Modesetting is required
    modesetting.enable = true;

    # Power management (experimental)
    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };
}
```

### Option 2: Beta Driver (Latest Features)

```nix
hardware.nvidia = {
  open = false;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.beta;
  modesetting.enable = true;
};
```

### Option 3: Vulkan Beta Driver (Bleeding Edge)

```nix
hardware.nvidia = {
  open = false;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
  modesetting.enable = true;
};
```

### Option 4: Production Driver (Data Centers)

```nix
hardware.nvidia = {
  open = false;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.production;
  modesetting.enable = true;
};
```

## Driver Verification

### Check NVIDIA Driver

```bash
# Check driver version
nvidia-smi

# Check Vulkan support
vulkaninfo --summary | grep -i nvidia

# Verify CUDA (if needed)
nvidia-smi --query-gpu=compute_cap --format=csv
```

### Check Vulkan Extensions

```bash
# Install verification tools
nix-shell -p vulkan-tools

# Check for required extensions
vulkaninfo | grep -E "VK_EXT_descriptor_indexing|VK_EXT_robustness2|VK_KHR_push_descriptor|VK_EXT_image_view_min_lod|VK_EXT_mutable_descriptor_type|VK_EXT_descriptor_buffer"
```

### Expected Output

```
Driver Version           : 550.90.07
CUDA Version             : 12.4
GPU Name                 : NVIDIA GeForce RTX 4090
Vulkan API Version       : 1.3.xxx
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

  # Kernel parameters for NVIDIA
  boot.kernelParams = [
    "nvidia-drm.modeset=1"           # Required for Wayland
    "nvidia-drm.fbdev=1"             # Framebuffer support
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # Suspend support
  ];

  # Kernel modules
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # Enable experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # User configuration
  users.users.YOUR_USERNAME = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "gamemode"
      "video"
      "input"
    ];
  };

  # Graphics - NVIDIA Configuration
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Use open source kernel module (RTX 20xx+)
    # Set to false for GTX 16xx and older
    open = true;

    # Enable NVIDIA settings
    nvidiaSettings = true;

    # Driver package (choose one)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    # package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;

    # Modesetting (required)
    modesetting.enable = true;

    # Power management
    powerManagement = {
      enable = true;
      finegrained = false;  # Set to true for laptop with hybrid graphics
    };

    # Prime (for laptops with hybrid graphics)
    # Uncomment and configure if you have Intel + NVIDIA
    # prime = {
    #   sync.enable = true;
    #   # offload.enable = true;
    #   # offload.enableOffloadCmd = true;
    #   intelBusId = "PCI:0:2:0";
    #   nvidiaBusId = "PCI:1:0:0";
    # };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Essential for Wine/Proton
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
        nv_powermizer_mode = 1;  # Maximum performance
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

  # Allow unfree packages (required for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # === NVIDIA Tools ===
    nvtopPackages.nvidia      # GPU monitoring
    nvidia-system-monitor-qt  # GUI GPU monitor

    # === Wine & Compatibility ===
    wineWowPackages.stable    # Wine 32/64-bit
    wineWowPackages.staging   # Wine Staging
    winetricks                # Wine helper scripts

    # === Gaming Platforms ===
    lutris                    # Multi-platform game launcher
    heroic                    # Epic Games & GOG launcher
    bottles                   # Wine prefix manager

    # === Performance Layers ===
    dxvk                      # DirectX 9/10/11 → Vulkan
    vkd3d-proton             # DirectX 12 → Vulkan
    gamemode                  # CPU/GPU optimizations
    mangohud                  # FPS/performance overlay
    goverlay                  # GUI for MangoHUD

    # === Proton Tools ===
    protonup-qt              # Manage Proton-GE
    protontricks             # Winetricks for Proton
    steamtinkerlaunch        # Advanced Steam tweaking

    # === Monitoring & Tools ===
    vulkan-tools             # vulkaninfo, vulkan-cube
    vulkan-validation-layers # Vulkan debugging
    glxinfo                  # OpenGL info

    # === Controllers ===
    linuxConsoleTools        # jstest, jscal
    antimicrox               # Controller mapping
    xboxdrv                  # Xbox controller

    # === Utilities ===
    wget
    curl
    fastfetch
    htop
  ];

  # Display server
  services.xserver.enable = true;

  # Desktop environment
  # X11 (better NVIDIA support)
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Wayland (experimental with NVIDIA)
  # services.displayManager.gdm.wayland = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  # System state version
  system.stateVersion = "25.05";
}
```

### flake.nix

```nix
// filepath: /home/a42/Nix/.dotfiles/flake.nix
{
  description = "NixOS Gaming Configuration - NVIDIA";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
  };
}
```

### home.nix - User Environment

```nix
// filepath: /home/a42/Nix/.dotfiles/home.nix
{ config, pkgs, ... }: {
  home.username = "YOUR_USERNAME";
  home.homeDirectory = "/home/YOUR_USERNAME";
  home.stateVersion = "25.05";

  # NVIDIA-specific environment variables
  home.sessionVariables = {
    # Force NVIDIA GPU
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # Wine/Proton optimizations
    WINEFSYNC = "1";
    WINEESYNC = "1";
    DXVK_ASYNC = "1";
    DXVK_STATE_CACHE_PATH = "$HOME/.cache/dxvk";

    # NVIDIA-specific
    PROTON_ENABLE_NVAPI = "1";        # Enable NVIDIA API
    PROTON_HIDE_NVIDIA_GPU = "0";     # Show NVIDIA GPU

    # MangoHUD
    MANGOHUD = "1";
    MANGOHUD_CONFIG = "gpu_temp,gpu_core_clock,gpu_mem_clock,vram,fps,frametime";
  };

  # MangoHUD config for NVIDIA
  home.file.".config/MangoHud/MangoHud.conf".text = ''
    fps
    frametime

    # NVIDIA specific
    gpu_temp
    gpu_core_clock
    gpu_mem_clock
    gpu_power
    vram

    cpu_temp
    ram

    position=top-right
    font_size=24
    background_alpha=0.5
    toggle_hud=Shift_R+F12
  '';

  programs.home-manager.enable = true;
}
```

## Performance Optimizations

### 1. NVIDIA Power Management

```bash
# Check current power mode
nvidia-smi -q -d PERFORMANCE

# Set maximum performance (manual)
sudo nvidia-smi -pm 1
sudo nvidia-smi -pl 350  # Adjust power limit (watts)

# Set persistence mode
sudo nvidia-smi -pm 1
```

### 2. Persistent NVIDIA Configuration

Add to `configuration.nix`:

```nix
# NVIDIA performance mode
systemd.services.nvidia-performance = {
  description = "Set NVIDIA GPU to maximum performance";
  wantedBy = [ "multi-user.target" ];
  after = [ "multi-user.target" ];

  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.linuxPackages.nvidia_x11}/bin/nvidia-smi -pm 1";
  };
};
```

### 3. NVIDIA Settings (GUI)

```bash
# Open NVIDIA Settings
nvidia-settings

# Key settings for gaming:
# - PowerMizer: Prefer Maximum Performance
# - Sync to VBlank: Off (for gaming)
# - Allow Flipping: On
# - Force Full Composition Pipeline: Off (adds latency)
```

### 4. Kernel Parameters

```nix
boot.kernelParams = [
  # NVIDIA
  "nvidia-drm.modeset=1"
  "nvidia-drm.fbdev=1"

  # Reduce input latency
  "threadirqs"

  # Disable watchdog
  "nowatchdog"
  "nmi_watchdog=0"

  # Memory management
  "vm.max_map_count=2147483642"
];
```

### 5. Coolbits (Overclocking)

```nix
# Enable overclocking in NVIDIA settings
services.xserver.deviceSection = ''
  Option "Coolbits" "28"
'';
```

Coolbits values:

- `1` - Basic overclock
- `2` - Fan control
- `4` - PowerMizer
- `8` - Extended overclock
- Combine by adding: `28` = 4+8+16 (full control)

## Gaming Platforms

### Steam

1. **Enable Proton for all games:**

   - Steam → Settings → Compatibility
   - Enable "Steam Play for all other titles"

2. **NVIDIA-specific launch options:**

   ```
   __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia mangohud gamemoderun %command%
   ```

3. **For laptops with hybrid graphics:**
   ```
   prime-run mangohud gamemoderun %command%
   ```

### Lutris

Configure NVIDIA-specific settings:

- System Options:
  - Enable DXVK
  - Enable VKD3D
  - Enable Esync/Fsync
  - Enable GameMode
- Environment Variables:
  ```
  __GLX_VENDOR_LIBRARY_NAME=nvidia
  PROTON_ENABLE_NVAPI=1
  DXVK_ASYNC=1
  ```

## Monitoring & Debugging

### NVIDIA GPU Monitoring

```bash
# Real-time monitoring
nvtop

# NVIDIA System Monitor (GUI)
nvidia-system-monitor

# Command line stats
nvidia-smi -l 1  # Update every second

# Detailed query
nvidia-smi -q
```

### Performance Profiling

```bash
# NVIDIA Nsight Systems
# Add to environment.systemPackages
pkgs.nsight-systems

# Profile a game
nsys profile --trace=cuda,nvtx,opengl,vulkan ./game
```

## Troubleshooting

### Issue: Black Screen After Update

1. **Boot into recovery:**

   - Select previous generation in bootloader

2. **Check driver status:**

   ```bash
   lsmod | grep nvidia
   ```

3. **Rebuild with older driver:**
   ```nix
   hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
   ```

### Issue: Screen Tearing

**For X11:**

Add to `configuration.nix`:

```nix
services.xserver.screenSection = ''
  Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
'';
```

Or use NVIDIA Settings:

- X Server Display Configuration
- Advanced
- Force Full Composition Pipeline

**For Wayland:**

- Screen tearing should be minimal on Wayland

### Issue: Low FPS or Stuttering

1. **Verify GPU is being used:**

   ```bash
   nvidia-smi  # Should show GPU activity
   ```

2. **Check power mode:**

   ```bash
   nvidia-smi -q -d PERFORMANCE
   # Should show "Max Performance"
   ```

3. **Disable composition (X11):**
   ```bash
   # Temporary
   nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceCompositionPipeline = Off }"
   ```

### Issue: Game Won't Launch

1. **Check if running on NVIDIA GPU:**

   ```bash
   # Launch with explicit NVIDIA
   __GLX_VENDOR_LIBRARY_NAME=nvidia %command%
   ```

2. **For hybrid graphics laptops:**

   ```bash
   prime-run %command%
   ```

3. **Verify Vulkan:**
   ```bash
   vulkaninfo | grep -i nvidia
   ```

### Issue: NVIDIA Driver Not Loading

1. **Check kernel module:**

   ```bash
   lsmod | grep nvidia
   modinfo nvidia
   ```

2. **Verify driver installation:**

   ```bash
   ls -l /run/opengl-driver/lib/libGL*
   ```

3. **Check Xorg logs:**
   ```bash
   cat /var/log/Xorg.0.log | grep -i nvidia
   ```

### Issue: Suspend/Resume Problems

Enable NVIDIA power management:

```nix
hardware.nvidia.powerManagement.enable = true;

boot.kernelParams = [
  "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
];

# Enable required services
systemd.services.nvidia-suspend.enable = true;
systemd.services.nvidia-hibernate.enable = true;
systemd.services.nvidia-resume.enable = true;
```

## Benchmark & Testing

### GPU Benchmarks

```bash
# Vulkan tests
vkcube
vulkaninfo

# OpenGL tests
glxgears
glmark2

# NVIDIA specific
nvidia-smi --query-gpu=name,driver_version,vbios_version --format=csv
```

### Gaming Benchmarks

- **3DMark** (via Steam/Proton)
- **Unigine Heaven**
- **Unigine Superposition**
- **Shadow of the Tomb Raider** (built-in benchmark)

## Hybrid Graphics (Laptops)

### NVIDIA Prime Configuration

For laptops with Intel + NVIDIA:

```nix
hardware.nvidia.prime = {
  # Sync mode (both GPUs always on)
  sync.enable = true;

  # Or offload mode (use NVIDIA on demand)
  # offload.enable = true;
  # offload.enableOffloadCmd = true;

  # Find your bus IDs with: lspci | grep -E "VGA|3D"
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
};
```

### Launch with NVIDIA (Offload Mode)

```bash
# Use prime-run command
prime-run glxinfo | grep "OpenGL renderer"
prime-run %command%  # For games
```

## Additional Resources

- [NVIDIA Linux Drivers](https://www.nvidia.com/en-us/drivers/unix/)
- [NVIDIA Vulkan Beta Drivers](https://developer.nvidia.com/vulkan-driver)
- [ProtonDB](https://www.protondb.com/)
- [NixOS NVIDIA Wiki](https://nixos.wiki/wiki/Nvidia)
- [Arch Linux NVIDIA Guide](https://wiki.archlinux.org/title/NVIDIA)

## Update Commands

```bash
# Update system and drivers
cd ~/.dotfiles && nix flake update && sudo nixos-rebuild switch --flake .

# Update NVIDIA driver specifically
# Edit configuration.nix to change driver version, then:
sudo nixos-rebuild switch --flake .

# Clean old generations
sudo nix-collect-garbage -d
```

## Notes

- **Wayland support** is improving but X11 is still recommended for gaming
- Always use **latest drivers** for best gaming performance
- **Vulkan beta drivers** often have fixes for latest games
- Screen tearing is common on X11, use ForceFullCompositionPipeline
- For **RTX 20xx and newer**, open kernel module is recommended
- Suspend/resume can be problematic, test thoroughly

---

**Last Updated:** October 2024  
**Tested on:** NixOS 25.05, NVIDIA Driver 550.90, RTX 4090  
**Compatibility:** GTX 900 series and newer
