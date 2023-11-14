{ config,
  pkgs,
  ...
}:
let
  domain = "grafana.xnee.net";
in
{
  security.acme.defaults.email = "acme@xnee.net";
  security.acme.acceptTerms = true;
  security.acme.certs."${domain}" = { };

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
        proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${builtins.toString(config.services.grafana.settings.server.http_port)}";
        proxyWebsockets = true;
      };
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3312;
        domain = domain;
        enforce_domain = true;
      };
    };
    provision = {
      datasources.settings.datasources = [
        {
          name = "prometheus";
          url = "http://localhost:9001";
          type = "prometheus";
          editable = false;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Node-Exporter";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/master/prometheus/node-exporter-full.json";
            hash = "sha256-J3gCHEuUAirt1zdwjSHT7EIBHg41W25ML24ISGCziac=";
          };
        }
      ];
    };
  };
}
