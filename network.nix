{ config, pkgs, ...}:
let
  hostname = "AMR22";
  dnsServers = [ "1.1.1.1" "1.0.0.1" ];
in {
  networking = {
    knownNetworkServices = ["Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge"];
    hostName = "${hostname}";
    computerName = "${hostname}";
    localHostName = "${hostname}";
    dns = dnsServers;
  };
}
