{ system, inputs, config, lib, pkgs, ... }:
{
  services.dnsproxy = {
    enable = true;
    flags = [
      "--listen=127.0.0.1"
      "--port=53"

      "--upstream=quic://dns.quad9.net:853"
      "--upstream=tls://dns.quad9.net:853"

      "--cache"
      "--cache-size=4194304"
      "--cache-min-ttl=2400"
      "--cache-max-ttl=86400"
      "--ipv6-disabled"
      "--bootstrap=9.9.9.9:53"
    ];
  };

  services.resolved.enable = false;
  networking.networkmanager.dns = "none";
  networking.nameservers = [ "127.0.0.1" ];
}
