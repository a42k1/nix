# Placeholder = https://nixos.wiki/wiki/Cheatsheet

## UPDATING - for full update follow this it like this.

```
1. nix flake update #updates flake.lock file
#So any subsequent switches [1] and [2] will use updated packages

2. [1] sudo nixos-rebuild switch --flake .
#updates packages for system

3. [2] home-manager switch --flake .
#updates packages for user
```

nix-channel --update #updates normal without flake good for troubleshooting
