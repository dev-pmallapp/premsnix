{ inputs }:
_final: _prev:
let
  premsnixLib = import ./default.nix { inherit inputs; };
in
{
  # Expose premsnix module functions directly
  premsnix = premsnixLib.flake.lib.module;

  # Expose all premsnix lib namespaces
  inherit (premsnixLib.flake.lib)
    file
    system
    theme
    base64
    ;

  inherit (premsnixLib.flake.lib.file)
    getFile
    getNixFiles
    importFiles
    importDir
    importModulesRecursive
    mergeAttrs
    ;

  inherit (premsnixLib.flake.lib.module)
    mkOpt
    mkOpt'
    mkBoolOpt
    mkBoolOpt'
    enabled
    disabled
    capitalize
    boolToNum
    default-attrs
    force-attrs
    nested-default-attrs
    nested-force-attrs
    decode
    ;

  # Add home-manager lib functions
  inherit (inputs.home-manager.lib) hm;
}
