{ inputs, lib, ... }:
let logfile = "/var/log/dnsmasq.log";
in
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.dnsmasq =
    {
      enable = true;
      servers =
        let
          cloudflare = [
            # https://developers.cloudflare.com/1.1.1.1/setup/linux/
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];

          google = [
            # https://developers.google.com/speed/public-dns/docs/using#linux
            "8.8.8.8"
            "8.8.4.4"
            "2001:4860:4860::8888"
            "2001:4860:4860::8844"
          ];

        in
        lib.concatLists [ cloudflare google ];

      extraConfig = ''
        domain-needed
        bogus-priv
        no-resolv
        no-poll
        log-queries

        cache-size=10000
        local-ttl=300
        log-facility=${logfile}

        conf-file=${inputs.hosts-blocklists}/dnsmasq/dnsmasq.blacklist.txt
      '';
    };

  services.logrotate = {
    enable = true;
    settings.dnsmasq = {
      enable = true;
      files = [ logfile ];
      frequency = "daily";
    };
  };
}
