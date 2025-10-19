# Placeholder = https://nixos.wiki/wiki/Cheatsheet

## UPDATING - for full update follow it like this.

```
1. nix flake update #Updates flake.lock file so any subsequent switches [1] and [2] will use updated packages

2. [1] sudo nixos-rebuild switch --flake
#updates packages for system

3. [2] home-manager switch --flake .
#updates packages for user

#in both of these --flake [directory] in this case . and #[configuration[1 hostname] [2 user]]
```

## Storage

```

```

## Security

```
# Scans unused code
nix run github:astro/deadnix example.nix

# Scans and removes unused code. No reason to use this
nix run github:astro/deadnix -- -eq test.nix
```
