{
  networking.firewall.allowedTCPPorts = [ 9100 ];
  services.prometheus = {
    enable = true;
    port = 9001;
    checkConfig = "syntax-only";
    scrapeConfigs = [
      {
        job_name = "node-exporter";
        scrape_interval = "20s";
        scheme = "http";
        static_configs = [{
          targets = [
            "192.168.10.10:9100" # tc1
            "192.168.10.11:9100" # tc2
          ];
        }];
      }
    ];
    exporters.node = {
      enable = true;
      listenAddress = "192.168.10.11";
      enabledCollectors = [
        "systemd"
        "ethtool"
      ];
  };
  };


}
