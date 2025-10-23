{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      self,
      self',
      system,
      config,
      ...
    }:
    let
      # Import the overlay configuration
      overlaysConfig = import ../overlays.nix {
        inherit inputs lib self;
      };

      # Custom pkgs instance for devshells
      devPkgs = import pkgs.path {
        inherit (pkgs) system;
        config = pkgs.config // {
          allowUnfree = true;
        };
        overlays = lib.attrValues overlaysConfig.flake.overlays;
      };

      shellsPath = ./shells;
      shellFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (
        builtins.readDir shellsPath
      );
      shellNames = lib.mapAttrsToList (name: _: lib.removeSuffix ".nix" name) shellFiles;

      buildShell = name: {
        ${name} = import (shellsPath + "/${name}.nix") {
          inherit
            config
            inputs
            lib
            self
            self'
            system
            ;
          inherit (devPkgs) mkShell;
          pkgs = devPkgs;
        };
      };
    in
    {
      devShells = lib.foldl' (acc: name: acc // buildShell name) { } shellNames;
    };
}
