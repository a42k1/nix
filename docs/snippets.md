# Placeholder = https://nixos.wiki/wiki/Cheatsheet

## UPDATING - for full update follow it like this.

```nix
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

## Git

```git
# Git add all except one file
git add -A && git reset <file-to-exclude>

# Fix SSH agent for git push (if hanging)
pkill -u $USER ssh-agent
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519

# Merge branch A into branch B
git checkout <target-branch>
git merge <source-branch>
git push origin <target-branch>

# Option 1: Stash uncommitted changes and switch branches
git stash push <filename>
git checkout <branch>
git push <branch>
git checkout <back-to-branch>
git stash pop  # Apply stashed changes back

# Option 2: Commit changes before merging
git add <filename>
git commit -m "WIP: description"
git checkout <target-branch>
git merge <source-branch>
```

## Security

```nix
# Scans unused code
nix run github:astro/deadnix example.nix

# Scans and removes unused code. No reason to use this
nix run github:astro/deadnix -- -eq test.nix
```

## Steam

HOST_LC_ALL=pt_BR.UTF-8 Para o jogo reconhecer servidor BR
mangohud p/ CHECAR FPS GPU CPU TEMPS
gamemoderun %command%

## Options
```nix
{configs, pkgs, ...}:
{
 lib.mkDefault true #sets priority value of 1000 
 lib.mkForce  false  #sets priority value of 50
 lib.mOverride 20 value #sets custom priority in this case 20
 # Example 1
  programs.bash.enable = lib.mkDefault false #disabled by default but declared. Prio 1000
  programs.bash.enable = true #gets enabled with no conflict. Prio 100 
  programs.bash.enable = lib.mkForce false #disables by force Prio 50
  programs.bash.enable = lib.mkOverride 20 true #enables by force over mkForce 20
 #the less priority value the stronger it is.
 programs.bash.enable = lib.mkOverride 51 true #disabled by mkForce
}
```

