# Caelestia + Hyprland Implementation Plan

## Overview

This guide will help you implement the Caelestia dotfiles with Hyprland on your NixOS system. Caelestia is a modern, feature-rich desktop shell built with Quickshell for Hyprland, featuring dynamic theming, custom widgets, and a beautiful aesthetic.

**Current System Context:**

- OS: NixOS (unstable branch)
- User: a42
- Home Manager: Enabled
- Shell: Zsh (with custom aliases in `sh.nix`)
- Desktop: Currently running GNOME + GDM
- Display Server: X11 (will migrate to Wayland with Hyprland)

**Video Reference:** [Caelestia Tutorial](https://www.youtube.com/watch?v=7QLhCgDMqgw&list=PLFEB03GawV38XqMta5P66lkNjYW3SokuW&index=3)

---

## Phase 1: Understanding Caelestia Architecture

### What is Caelestia?

Caelestia is a complete desktop environment rice consisting of:

1. **Caelestia Shell** - Desktop shell built with Quickshell (replaces Waybar/eww)
2. **Caelestia CLI** - Command-line tool for controlling the shell and system
3. **Hyprland** - Wayland compositor and window manager
4. **Configuration Files** - Dotfiles for various applications

### Key Components:

- **Quickshell**: Qt6-based shell framework for creating desktop widgets
- **Hyprland**: Modern Wayland compositor
- **Dynamic Theming**: Colors change based on wallpaper
- **Custom Widgets**: Dashboard, launcher, notifications, media controls, etc.

---

## Phase 2: Prerequisites & Dependencies

### 2.1 Add Caelestia to Flake Inputs

**File to modify:** `/home/nix/flake.nix`

Add to the `inputs` section:

```nix
caelestia-shell = {
  url = "github:caelestia-dots/shell";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### 2.2 Core System Dependencies

Create a list of required packages that need to be installed. These will be added to your configuration in later phases.

**Essential Packages:**

- `hyprland` - Window manager
- `xdg-desktop-portal-hyprland` - Portal for Hyprland
- `xdg-desktop-portal-gtk` - GTK portal implementation
- `hyprpicker` - Color picker for Hyprland
- `wl-clipboard` - Wayland clipboard utilities (you already have this!)
- `cliphist` - Clipboard history manager
- `inotify-tools` - File system event monitoring
- `wireplumber` - PipeWire session manager (already have PipeWire)
- `trash-cli` - Command-line trash management
- `brightnessctl` - Brightness control
- `ddcutil` - Monitor control utility
- `app2unit` - systemd unit wrapper for apps

**Terminal & Shell:**

- `foot` - Fast, lightweight Wayland terminal
- `fish` - Friendly interactive shell (Caelestia uses this alongside zsh)
- `starship` - Cross-shell prompt

**System Monitoring & Info:**

- `fastfetch` - System information tool (you already have this!)
- `btop` - Resource monitor
- `lm_sensors` - Hardware monitoring
- `networkmanager` - Network management (you already have this!)

**Utilities:**

- `jq` - JSON processor
- `eza` - Modern replacement for ls
- `libnotify` - Desktop notifications

**Fonts:**

- `material-symbols` - Material Design icons
- `nerd-fonts.caskaydia-cove` - CaskaydiaCove Nerd Font
- You already have: `nerd-fonts.jetbrains-mono`

**Audio/Media:**

- `aubio` - Audio analysis library
- `libcava` - Audio visualizer library
- `libpipewire` - PipeWire library

**Graphics/Theming:**

- `libqalculate` - Calculator library
- `swappy` - Screenshot annotation tool
- `adw-gtk-theme` - Adwaita GTK theme
- `papirus-icon-theme` - Icon theme
- `qt5ct-kde` - Qt5 configuration tool
- `qt6ct-kde` - Qt6 configuration tool

**Build Dependencies (for custom builds if needed):**

- `cmake`
- `ninja`
- `gcc`
- `qt6-declarative`
- `vulkan-tools`
- `vulkan-validation-layers`

---

## Phase 3: System Configuration Setup

### 3.1 Create Hyprland Module

**File to create:** `/home/nix/system/hyprland.nix`

This file will contain the system-level Hyprland configuration:

```nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Environment variables for Wayland/Hyprland
  environment.sessionVariables = {
    # Hint electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
    # Set Hyprland as the window manager
    WLR_NO_HARDWARE_CURSORS = "1";
    # XDG specifications
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # System packages needed for Hyprland
  environment.systemPackages = with pkgs; [
    # Hyprland utilities
    hyprpicker
    hyprcursor
    hyprpaper

    # Wayland essentials
    wl-clipboard
    cliphist

    # System utilities
    brightnessctl
    ddcutil
    inotify-tools

    # Monitoring
    lm_sensors

    # Misc
    trash-cli
    libnotify
    jq
  ];

  # Enable brightness control for users in video group
  # (You already have user a42 in video group)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';
}
```

### 3.2 Update Main Configuration

**File to modify:** `/home/nix/system/configuration.nix`

Add the Hyprland module to imports:

```nix
imports = [
  ./hardware-configuration.nix
  ./gaming.nix
  ./hyprland.nix  # Add this line
];
```

**Note:** You can keep GDM and GNOME enabled alongside Hyprland initially. GDM will show both GNOME and Hyprland as session options. Once you're comfortable with Hyprland, you can disable GNOME.

To disable GNOME later (optional):

```nix
# Comment these out when ready to fully switch:
# services.displayManager.gdm.enable = true;
# services.desktopManager.gnome.enable = true;
```

---

## Phase 4: Home Manager Configuration

### 4.1 Add Caelestia Shell Package

**File to modify:** `/home/nix/user/home.nix`

Update the packages section:

```nix
home.packages = with pkgs; [
  hello
  wl-clipboard

  # Terminal & Shell
  foot
  starship
  fish

  # System utilities
  btop
  fastfetch
  eza

  # Caelestia dependencies
  libqalculate
  swappy
  aubio

  # Themes
  adw-gtk-theme
  papirus-icon-theme

  # Fonts
  nerd-fonts.caskaydia-cove
];
```

Add Caelestia shell (reference from flake input):

```nix
# In your flake.nix, pass caelestia-shell to home-manager modules
# Then in home.nix:
home.packages = with pkgs; [
  # ... existing packages ...
  inputs.caelestia-shell.packages.${pkgs.system}.with-cli
];
```

### 4.2 Configure Shell Aliases

**File to modify:** `/home/nix/user/sh.nix`

Add Caelestia-specific aliases:

```nix
aliases = {
  # ... existing aliases ...

  # Caelestia aliases
  clip = "wl-copy";  # Clipboard copy
  paste = "wl-paste";  # Clipboard paste
  cat = "bat";  # Better cat (optional, requires bat package)
  ls = "eza --icons";  # Modern ls replacement
  ll = "eza -l --icons";
  la = "eza -la --icons";
  tree = "eza --tree --icons";
};
```

### 4.3 Create Hyprland User Configuration Module

**File to create:** `/home/nix/user/hyprland.nix`

```nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Hyprland configuration via Home Manager
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      # You'll populate this with Caelestia's Hyprland config
      # For now, basic settings

      "$mod" = "SUPER";

      # Keybindings
      bind = [
        "$mod, T, exec, foot"
        "$mod, C, exec, code"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, Space, togglefloating"
        "$mod, RETURN, exec, caelestia-shell"

        # Workspace bindings
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"

        # Move to workspace
        "$mod ALT, 1, movetoworkspace, 1"
        "$mod ALT, 2, movetoworkspace, 2"
        "$mod ALT, 3, movetoworkspace, 3"
        "$mod ALT, 4, movetoworkspace, 4"
        "$mod ALT, 5, movetoworkspace, 5"
      ];

      # Autostart
      exec-once = [
        "caelestia-shell -d"
        "wl-paste --watch cliphist store"
      ];

      # Basic appearance
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(9ccbfbff)";
        "col.inactive_border" = "rgba(101418ff)";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
        };
        drop_shadow = true;
        shadow_range = 20;
        shadow_render_power = 3;
      };

      animations = {
        enabled = true;
        bezier = "easeOutExpo, 0.16, 1, 0.3, 1";
        animation = [
          "windows, 1, 3, easeOutExpo"
          "windowsOut, 1, 3, easeOutExpo, popin 80%"
          "border, 1, 5, easeOutExpo"
          "fade, 1, 3, easeOutExpo"
          "workspaces, 1, 3, easeOutExpo"
        ];
      };
    };
  };
}
```

### 4.4 Update Home Manager Imports

**File to modify:** `/home/nix/user/home.nix`

```nix
imports = [
  ./sh.nix
  ./hyprland.nix  # Add this line
];
```

---

## Phase 5: Dotfiles Directory Structure

### 5.1 Plan Your Dotfiles Structure

Create this structure in `/home/nix/dotfiles/`:

```
dotfiles/
├── hypr/           # Hyprland configs (will be populated with Caelestia's)
├── foot/           # Foot terminal configs
├── fish/           # Fish shell configs
├── btop/           # Btop configs
├── fastfetch/      # Fastfetch configs
├── vscode/         # VSCode configs (you already have this symlinked)
└── caelestia/      # Caelestia-specific configs (shell.json)
```

### 5.2 Add to Home Manager Symlinks

**File to modify:** `/home/nix/user/home.nix`

Update the configs mapping:

```nix
configs = {
  vscode = "vscode";
  hypr = "hypr";
  foot = "foot";
  fish = "fish";
  btop = "btop";
  fastfetch = "fastfetch";
  caelestia = "caelestia";
};
```

---

## Phase 6: Clone and Adapt Caelestia Configs

### 6.1 Clone Caelestia Repositories

**Terminal commands:**

```bash
# Create a temporary directory for Caelestia
mkdir -p ~/temp/caelestia-setup
cd ~/temp/caelestia-setup

# Clone the main Caelestia config repo
git clone https://github.com/caelestia-dots/caelestia.git

# Clone the shell repo (for reference)
git clone https://github.com/caelestia-dots/shell.git

# Clone the CLI repo (for reference)
git clone https://github.com/caelestia-dots/cli.git
```

### 6.2 Copy Relevant Configs to Your Dotfiles

**Copy these configurations:**

```bash
# Navigate to your dotfiles directory
cd /home/nix/dotfiles

# Copy Hyprland configs
mkdir -p hypr
cp -r ~/temp/caelestia-setup/caelestia/hypr/* hypr/

# Copy Foot terminal configs
mkdir -p foot
cp -r ~/temp/caelestia-setup/caelestia/foot/* foot/

# Copy Fish configs
mkdir -p fish
cp -r ~/temp/caelestia-setup/caelestia/fish/* fish/

# Copy Btop configs
mkdir -p btop
cp -r ~/temp/caelestia-setup/caelestia/btop/* btop/

# Copy Fastfetch configs
mkdir -p fastfetch
cp -r ~/temp/caelestia-setup/caelestia/fastfetch/* fastfetch/

# Create Caelestia shell config directory
mkdir -p caelestia
```

### 6.3 Create Caelestia Configuration File

**File to create:** `/home/nix/dotfiles/caelestia/shell.json`

```json
{
  "wallpapersPath": "/home/a42/Pictures/Wallpapers",
  "pfpPath": "/home/a42/.face",
  "terminal": "foot",
  "browser": "firefox",
  "ide": "code",
  "enableAnimations": true,
  "enableBlur": true,
  "dashboardModules": {
    "weather": false,
    "system": true,
    "media": true,
    "quicksettings": true
  }
}
```

### 6.4 Customize Hyprland Config for Your System

**File to review/edit:** `/home/nix/dotfiles/hypr/hyprland.conf`

Key things to customize:

- Monitor configuration (resolution, position)
- Input devices (keyboard layout, mouse sensitivity)
- AMD GPU specific settings (you have AMD, this is important!)
- Workspace rules

**Create a user override file:**
**File to create:** `/home/nix/dotfiles/hypr/hypr-user.conf`

```conf
# Your personal Hyprland overrides
# This file is sourced by the main hyprland.conf

# Monitor setup - adjust to your monitors
monitor=,preferred,auto,1

# AMD GPU optimizations (you're running AMD!)
env = WLR_DRM_NO_ATOMIC,1

# Disable VRR if you experience flickering
misc {
    vrr = 0
}

# Your custom keybinds
# Example: Add screenshot with Print key
bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -

# Your custom autostart programs
exec-once = discord
exec-once = firefox
```

---

## Phase 7: Wallpapers and Theming

### 7.1 Setup Wallpaper Directory

```bash
# Create wallpapers directory
mkdir -p ~/Pictures/Wallpapers

# Download some starter wallpapers or copy your existing ones
# Caelestia works best with at least 3-5 wallpapers
```

### 7.2 Setup Profile Picture

```bash
# Copy or link your profile picture
cp /path/to/your/picture.jpg ~/.face

# Or create a placeholder
convert -size 512x512 xc:blue -fill white -pointsize 72 \
  -draw "text 180,280 'A42'" ~/.face.png
ln -s ~/.face.png ~/.face
```

**Note:** You'll need `imagemagick` for the convert command, or just use any image.

### 7.3 Understanding Dynamic Theming

Caelestia can generate color schemes from your wallpaper:

- Uses `caelestia scheme` command
- Analyzes wallpaper colors
- Generates matching theme for shell, terminal, etc.
- Automatically applies across all apps

**Commands to use after setup:**

```bash
# Set wallpaper and generate theme
caelestia wallpaper -f ~/Pictures/Wallpapers/your-wallpaper.jpg

# Set dynamic scheme
caelestia scheme set -n dynamic

# List available schemes
caelestia scheme list
```

---

## Phase 8: Build and Deploy

### 8.1 Update Flake Lock

```bash
cd /home/nix
nix flake update
```

### 8.2 Build System Configuration

```bash
# Build but don't activate (for testing)
sudo nixos-rebuild build --flake .#nix42

# If successful, activate
sudo nixos-rebuild switch --flake .#nix42
```

### 8.3 Build Home Manager Configuration

```bash
# Build home manager config
home-manager switch --flake .#a42
```

### 8.4 Reboot or Switch Session

**Option 1: Reboot (recommended for first time)**

```bash
sudo reboot
```

**Option 2: Switch session without rebooting**

- Log out of GNOME
- At GDM login screen, click the gear icon
- Select "Hyprland"
- Log in

---

## Phase 9: First Boot and Configuration

### 9.1 Initial Hyprland Launch

After logging into Hyprland:

1. You should see the Caelestia shell loading
2. Press `Super` to open the launcher
3. Press `Super + T` to open a terminal (Foot)

### 9.2 Test Core Functionality

**In terminal, test these commands:**

```bash
# Check if Caelestia CLI is available
caelestia --help

# Test shell IPC
caelestia shell -s

# Test wallpaper functionality
caelestia wallpaper list

# Test system info
fastfetch

# Test clipboard
echo "test" | wl-copy
wl-paste
```

### 9.3 Configure Caelestia

**Set your first wallpaper:**

```bash
caelestia wallpaper -f ~/Pictures/Wallpapers/your-wallpaper.jpg
```

**Generate and apply dynamic theme:**

```bash
caelestia scheme set -n dynamic
```

### 9.4 Verify Services

**Check if required services are running:**

```bash
# Check PipeWire audio
wpctl status

# Check network
nmcli device status

# Check clipboard history
cliphist list | head
```

---

## Phase 10: Customization and Fine-Tuning

### 10.1 Adjust Hyprland Settings

Edit `/home/nix/dotfiles/hypr/hypr-user.conf` for:

- Monitor layouts
- Animation speeds
- Workspace rules
- Application-specific rules

### 10.2 Customize Keybindings

**Common keybinds to consider:**

```conf
# Screenshot region
bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -

# Screenshot full screen
bind = SHIFT, Print, exec, grim - | swappy -f -

# Color picker
bind = $mod SHIFT, C, exec, hyprpicker -a

# Lock screen
bind = $mod, L, exec, caelestia shell lock lock

# Volume controls (if not working)
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness controls
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
```

### 10.3 Configure Gaming with Hyprland

**Add to `/home/nix/dotfiles/hypr/hypr-user.conf`:**

```conf
# Gaming optimizations
windowrulev2 = immediate, class:^(steam_app_.*)$
windowrulev2 = immediate, class:^(lutris)$
windowrulev2 = immediate, title:^(.*Proton.*)$

# Disable animations for games
windowrulev2 = noanim, class:^(steam_app_.*)$

# Fullscreen games on correct workspace
windowrulev2 = workspace 6, class:^(steam_app_.*)$
```

### 10.4 Integrate with Your Existing Aliases

Your custom aliases in `sh.nix` will still work! Test them:

```bash
syu  # Update system
hmr  # Rebuild home-manager
```

---

## Phase 11: Application Integration

### 11.1 Configure VSCode for Wayland

**Update VSCode flags** (if needed):
Create/edit `~/.config/code-flags.conf`:

```
--enable-features=UseOzonePlatform,WaylandWindowDecorations
--ozone-platform=wayland
```

### 11.2 Configure Firefox for Wayland

Firefox should work automatically with Wayland, but verify:

```bash
# Check if Firefox is using Wayland
echo $MOZ_ENABLE_WAYLAND  # Should be "1"
```

### 11.3 Configure Discord

Install Discord with Wayland support:

```nix
# In your home.nix or system packages
(discord.override {
  withOpenASL = true;
  withVencord = true;  # Optional: for better Discord
})
```

---

## Phase 12: Troubleshooting

### 12.1 Common Issues and Solutions

**Issue: Shell doesn't start**

```bash
# Check logs
journalctl --user -xe | grep caelestia

# Try starting manually
caelestia-shell -d

# Check if Quickshell is installed
which qs
```

**Issue: Black screen / artifacts with AMD GPU**

```conf
# Add to hypr-user.conf
env = WLR_DRM_NO_ATOMIC,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
```

**Issue: Flickering screen**

```conf
# Disable VRR in hypr-user.conf
misc {
    vrr = 0
}
```

**Issue: Apps don't use Wayland**

```bash
# Check XDG portal
systemctl --user status xdg-desktop-portal-hyprland
systemctl --user status xdg-desktop-portal

# Restart portals
systemctl --user restart xdg-desktop-portal-hyprland
systemctl --user restart xdg-desktop-portal
```

**Issue: No sound in Hyprland**

```bash
# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber

# Check audio devices
wpctl status
```

**Issue: Clipboard not working**

```bash
# Restart cliphist
pkill -9 wl-paste
wl-paste --watch cliphist store &
```

### 12.2 Debugging Commands

```bash
# Check Hyprland version
hyprctl version

# List all windows
hyprctl clients

# Monitor system info
hyprctl monitors

# Check active window
hyprctl activewindow

# Reload Hyprland config
hyprctl reload
```

---

## Phase 13: Advanced Features

### 13.1 Setup Dynamic Wallpapers

Create wallpaper rotation script:

```bash
# Random wallpaper on login
caelestia wallpaper -r

# Time-based wallpaper
# Add to crontab or systemd timer
```

### 13.2 Setup Notification System

Caelestia includes built-in notifications, but verify:

```bash
# Test notification
notify-send "Test" "This is a test notification"

# Check notification history
caelestia shell notifs clear
```

### 13.3 Setup Media Controls

```bash
# Control media playback
caelestia shell mpris playPause
caelestia shell mpris next
caelestia shell mpris previous

# Get current track info
caelestia shell mpris getActive trackTitle
caelestia shell mpris getActive artist
```

### 13.4 Setup Dashboard Modules

Edit `~/.config/caelestia/shell.json` to enable/disable:

- System info
- Media player
- Weather (requires API key)
- Quick settings
- Notifications

---

## Phase 14: Maintenance

### 14.1 Updating Caelestia

```bash
# Update flake inputs
cd /home/nix
nix flake update caelestia-shell

# Rebuild
sudo nixos-rebuild switch --flake .#nix42
home-manager switch --flake .#a42
```

### 14.2 Backup Your Configs

Your configs are already version controlled in `/home/nix`:

```bash
cd /home/nix
git add .
git commit -m "Updated Caelestia configuration"
git push
```

### 14.3 Monitor Disk Usage

Caelestia adds packages, monitor with your aliases:

```bash
nix-size      # Check Nix store size
gc-check      # Preview garbage collection
gc-run        # Run garbage collection
```

---

## Phase 15: Optional Enhancements

### 15.1 Add Spicetify (Themed Spotify)

If you use Spotify, add Caelestia theme:

```nix
# In home.nix or system config
programs.spicetify = {
  enable = true;
  theme = "caelestia";
};
```

### 15.2 Add Themed Firefox

Apply Caelestia Firefox theme (CaelestiaFox).

### 15.3 Setup Screen Lock

Configure swaylock or hyprlock:

```bash
# Lock screen
caelestia shell lock lock

# Unlock
caelestia shell lock unlock
```

### 15.4 Setup Screen Recording

Add screen recording tools:

```nix
# Add to packages
wf-recorder    # Wayland screen recorder
grim           # Screenshot utility
slurp          # Region selector
```

---

## Quick Reference Card

### Essential Keybindings

- `Super` - Open launcher
- `Super + T` - Terminal
- `Super + C` - IDE (VSCode)
- `Super + W` - Browser
- `Super + Q` - Close window
- `Super + F` - Fullscreen
- `Super + Space` - Toggle floating
- `Super + 1-9` - Switch workspace
- `Super + Alt + 1-9` - Move window to workspace
- `Ctrl + Alt + Delete` - Session menu
- `Ctrl + Super + Space` - Media play/pause
- `Ctrl + Super + Alt + R` - Restart shell

### Essential Commands

```bash
# System management
syu                          # Update system
hmr                          # Rebuild home-manager
syr                          # Quick system rebuild

# Caelestia
caelestia wallpaper -f FILE  # Set wallpaper
caelestia scheme set         # Set color scheme
caelestia shell -s           # Show IPC commands

# Clipboard
echo "text" | wl-copy        # Copy to clipboard
wl-paste                     # Paste from clipboard
cliphist list               # Show clipboard history

# System info
fastfetch                   # System information
btop                        # System monitor
```

---

## Resources

- **Caelestia Shell Repo:** https://github.com/caelestia-dots/shell
- **Caelestia Dotfiles:** https://github.com/caelestia-dots/caelestia
- **Video Tutorial:** https://www.youtube.com/watch?v=7QLhCgDMqgw
- **Hyprland Wiki:** https://wiki.hyprland.org/
- **Quickshell Docs:** https://quickshell.outfoxxed.me/
- **NixOS Wiki:** https://nixos.wiki/

---

## Next Steps

1. ✅ Read through this entire plan
2. ⬜ Backup your current configuration
3. ⬜ Update `flake.nix` with Caelestia input
4. ⬜ Create `hyprland.nix` system module
5. ⬜ Update `home.nix` with required packages
6. ⬜ Create `hyprland.nix` user module
7. ⬜ Clone Caelestia repositories
8. ⬜ Copy configurations to dotfiles
9. ⬜ Create `shell.json` config
10. ⬜ Setup wallpapers directory
11. ⬜ Build and test configurations
12. ⬜ Reboot into Hyprland
13. ⬜ Configure and customize
14. ⬜ Profit! 🚀

---

**Note:** This is a comprehensive plan. Take it one phase at a time. Test after each major change. Keep backups. Have fun! 🎨
