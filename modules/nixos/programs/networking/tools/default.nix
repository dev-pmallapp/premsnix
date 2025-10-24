{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types getName;
  cfg = config.premsnix.programs.networking.tools;
  netPkgs = with pkgs; [
    bandwhich
    dig
    doggo
    ethtool
    gping
    hurl
    iperf3
    mtr
    netdiscover
    nmap
    rustscan
    speedtest-rs
    wakeonlan
    tcpdump
    hping
    net-tools # provides arp, rarp utilities
    arping
    traceroute
  ];
  doc = "Enable a curated set of networking, diagnostics and packet tools (inspired by Aeon-snowfall).";
  opt = lib.mkEnableOption doc;
  # Export list for other modules if needed
in
{
  options.premsnix.programs.networking.tools = {
    enable = opt;
    extraPackages = lib.mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to append to the networking tools set.";
    };
    excludePackages = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of package names to exclude from the curated networking tools (match by pname/getName).";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        filtered = builtins.filter (p: !(builtins.elem (getName p) cfg.excludePackages)) netPkgs;
      in
      filtered ++ cfg.extraPackages;

    # Allow network capture groups when tools enabled
    premsnix.user.extraGroups = lib.mkAfter [
      "network"
      "wireshark"
    ];
  };
}
