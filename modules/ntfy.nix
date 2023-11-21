let
  domain = "ntfy.xnee.net";
in
{
  security.acme.certs."n" = { };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    virtualHosts."${domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2586";
        proxyWebsockets = true;
      };
    };
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = "127.0.0.1:2586";
      base-url = "https://ntfy.xnee.net";
    };
  };
}
