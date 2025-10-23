{
  lib,
  host ? null,

  ...
}:
let
  inherit (lib) types;
  inherit (lib.premunix) mkOpt;
in
{
  options.premunix.host = {
    name = mkOpt (types.nullOr types.str) host "The host name.";
  };
}
