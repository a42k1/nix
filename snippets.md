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

## Git

```
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
git stash pop  # Apply stashed changes back

# Option 2: Commit changes before merging
git add <filename>
git commit -m "WIP: description"
git checkout <target-branch>
git merge <source-branch>
```

## Security

```
# Scans unused code
nix run github:astro/deadnix example.nix

# Scans and removes unused code. No reason to use this
nix run github:astro/deadnix -- -eq test.nix
```
