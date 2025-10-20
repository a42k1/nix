# TODO: Migrate /home/a42 to /home

## Current Setup

- Root partition: `/` mounted from `f3f3216e-5eef-4724-a2cb-ac5e4870810c`
- Home partition: `/home/a42` mounted from `ef394725-6efc-4a3c-8438-a7758b4101a2`
- User directory: `/home/a42/a42k1`
- Dotfiles: `/home/a42/Nix/.dotfiles`

## Goal

Migrate the `/home/a42` partition to be mounted as `/home` instead.

## Prerequisites

- [ ] Backup all important data from `/home/a42`
  ```bash
  sudo rsync -av /home/a42/ /path/to/backup/
  ```
- [ ] Create NixOS live USB (in case something goes wrong)

## Migration Steps

### 1. Boot into NixOS Live Environment

- [ ] Boot from NixOS installer USB
- [ ] Connect to internet if needed

### 2. Mount Partitions

```bash
# Mount root partition
sudo mount /dev/disk/by-uuid/f3f3216e-5eef-4724-a2cb-ac5e4870810c /mnt

# Create temporary mount point
sudo mkdir -p /mnt/tmp-mount

# Mount home partition to temporary location
sudo mount /dev/disk/by-uuid/ef394725-6efc-4a3c-8438-a7758b4101a2 /mnt/tmp-mount
```

### 3. Reorganize Data

```bash
# Move all data from /a42 subdirectory to root of partition
cd /mnt/tmp-mount

# Move regular files and directories
sudo mv a42/* ./

# Move hidden files (ignore errors for . and ..)
sudo mv a42/.* ./ 2>/dev/null || true

# Remove now-empty a42 directory
sudo rmdir a42

# Verify the move
ls -la /mnt/tmp-mount/
# Should see: a42k1/ Nix/ (and other files if any)
```

### 4. Remount Properly

```bash
# Unmount from temporary location
sudo umount /mnt/tmp-mount

# Create /home directory in root partition
sudo mkdir -p /mnt/home

# Mount home partition to /home
sudo mount /dev/disk/by-uuid/ef394725-6efc-4a3c-8438-a7758b4101a2 /mnt/home

# Verify user directory exists
ls -la /mnt/home/
# Should see: a42k1/
```

### 5. Update Configuration

```bash
# Mount boot partition (usually auto-detected, but just in case)
sudo mount /dev/disk/by-label/boot /mnt/boot  # Or check hardware-configuration.nix for UUID

# Navigate to dotfiles
cd /mnt/home/a42k1/Nix/.dotfiles
```

- [ ] Edit `configuration.nix`:

  ```nix
  # Remove this:
  # fileSystems."/home/a42" = {
  #   device = "/dev/disk/by-uuid/ef394725-6efc-4a3c-8438-a7758b4101a2";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };

  # Add this:
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/ef394725-6efc-4a3c-8438-a7758b4101a2";
    fsType = "ext4";
    options = [ "defaults" ];
  };
  ```

- [ ] Edit `system.autoUpgrade` flake path in `configuration.nix`:

  ```nix
  system.autoUpgrade = {
    enable = true;
    flake = "path:/home/a42k1/Nix/.dotfiles";  # Changed from /home/a42/Nix/.dotfiles
    # ...
  };
  ```

- [ ] Edit `home.nix` aliases:
  ```nix
  let
    aliases = {
      hmu = "cd ~/Nix/.dotfiles && nix flake lock --update-input home-manager && home-manager switch --flake .";
      sysu = "sudo nixos-rebuild switch --flake ~/Nix/.dotfiles";
      ll = "ls -l";
      ".." = "cd ..";
    };
  ```

### 6. Rebuild System

```bash
# Rebuild from live environment
sudo nixos-rebuild switch --flake /mnt/home/a42k1/Nix/.dotfiles --root /mnt
```

### 7. Reboot

```bash
# Unmount all partitions
sudo umount /mnt/home
sudo umount /mnt/boot
sudo umount /mnt

# Reboot
sudo reboot
```

### 8. Post-Migration Verification

After rebooting into your system:

- [ ] Verify home is mounted correctly:

  ```bash
  df -h | grep home
  # Should show: /dev/... mounted on /home
  ```

- [ ] Verify user directory:

  ```bash
  ls -la ~
  # Should show your files
  pwd
  # Should show: /home/a42k1
  ```

- [ ] Test aliases:

  ```bash
  hmu  # Should work
  syu  # Should work
  ```

- [ ] Rebuild once more to ensure everything works:

  ```bash
  sudo nixos-rebuild switch --flake ~/Nix/.dotfiles
  ```

- [ ] Test home-manager:
  ```bash
  home-manager switch --flake ~/Nix/.dotfiles
  ```

## Rollback Plan (If Something Goes Wrong)

If the migration fails:

1. Boot back into live environment
2. Mount partitions as before
3. Reverse the data move:
   ```bash
   sudo mkdir -p /mnt/tmp-mount/a42
   sudo mv /mnt/tmp-mount/* /mnt/tmp-mount/a42/
   ```
4. Revert configuration.nix changes
5. Rebuild with old configuration
6. Restore from backup if needed

## Notes

- Current user: `a42k1`
- New home path will be: `/home/a42k1`
- Dotfiles will be at: `/home/a42k1/Nix/.dotfiles`
- All references to `/home/a42/` in configs need to become `/home/a42k1/`

## Completion Checklist

- [ ] Backup completed
- [ ] Data successfully moved
- [ ] Configuration updated
- [ ] System rebuilt successfully
- [ ] System boots correctly
- [ ] User can login
- [ ] Home directory accessible
- [ ] Aliases work
- [ ] Applications work
- [ ] Delete this TODO file after successful migration
