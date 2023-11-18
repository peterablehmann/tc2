{
  config,
  inputs,
  ...
}:
{
  sops.secrets."fritzbox/password" = {
    sopsFile = "${inputs.self}/secrets/prometheus.yaml";
  };
  networking.firewall.allowedTCPPorts = [ 9100 ];
  services.prometheus = {
    enable = true;
    port = 9001;
    checkConfig = "syntax-only";
    scrapeConfigs = [
      {
        job_name = "node-exporter";
        scrape_interval = "10s";
        scheme = "http";
        static_configs = [{
          targets = [
            "192.168.10.10:9100" # tc1
            "192.168.10.11:9100" # tc2
          ];
        }];
      }
      {
        job_name = "fritzbox";
        scrape_interval = "10s";
        scheme = "http";
        static_configs = [{
          targets = [
            "127.0.0.1:9133"
          ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        listenAddress = "192.168.10.11";
        enabledCollectors = [
          "systemd"
          "ethtool"
        ];
      };
      fritzbox = {
        enable = true;
        gatewayAddress = "192.168.10.1";
        listenAddress = "127.0.0.1";
        extraFlags = [
          "-username prometheus"
          "-password $(cat ${config.sops.secrets."fritzbox/password".path})"
        ];
      };
    };
  };


}
