{
  pkgs,
  inputs,
  system,
  ...
}: {
  # install package
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default
    # ... maybe other stuff
  ];
}
