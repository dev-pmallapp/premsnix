{
  lib,
  host ? null,

  ...
}:
let
  inherit (lib) types;
  inherit (lib.premsnix) mkOpt;
in
{
  options.premsnix.host = {
    name = mkOpt (types.nullOr types.str) host "The host name.";
  };
}
