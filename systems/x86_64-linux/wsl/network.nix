{
  ...
}:
{
  # Minimal networking for WSL - inherited from host
  networking = {
    useDHCP = false;
    interfaces = { };
    firewall.enable = false;
  };

  systemd.network.enable = false;
}
