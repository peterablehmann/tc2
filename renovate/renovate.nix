{ config, lib, pkgs, ... }:

let
  cfg = config.services.renovate;
  settingsFormat = pkgs.formats.json { };
  settingsFile = settingsFormat.generate "config.json" cfg.settings;
in {
  options = {
    services.renovate = {
      enable = lib.mkEnableOption (lib.mdDoc "Renovatebot");

      environmentFiles = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        example = [ "/etc/renovate/environment.env" ];
        description = lib.mdDoc ''
          Set environment files for renovate.
        '';
      };

      path = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        # example = [ "pkgs.poetry" ];
        description = lib.mdDoc ''
          Renovate needs access to language specific tooling to perform it's tasks.
        '';
      };

      settings = lib.mkOption {
        default = { };
        type = settingsFormat.type;
        description = lib.mdDoc ''
          Set settings for renovate.
          See https://docs.renovatebot.com/self-hosted-configuration/ for possible values
        '';
      };

      interval = lib.mkOption {
        default = "1h";
        type = lib.types.str;
        description = lib.mdDoc ''
          Set the run interval for the renovate service.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.timers."renovate" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = cfg.interval;
        Unit = "renovate.service";
      };
    };  

    systemd.services.renovate = {
      wants = [ "network.target" ];
      after = [ "network.target" ];
      description = "Renovate Service";
      path = lib.concat [ pkgs.git ] cfg.path;
      environment = { RENOVATE_CONFIG_FILE = settingsFile; };
      serviceConfig = {
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${pkgs.callPackage ./package.nix { }}/bin/renovate";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 15;
      };
    };
  };
}
