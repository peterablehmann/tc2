{ config, lib, pkgs, ... }:

let
  cfg = config.services.renovate;
  settingsFormat = pkgs.format.json { };
  settingsFile = settingsFormat.generate "config.json" cfg.settings;
in {
  inherit (pkgs.renovate) meta.maintainers;

  options = {
    services.renovate = {
      enable = mkEnableOption (lib.mdDoc "Renovatebot");

      environmentFiles = lib.mkOption {
        type = lib.types.listOf.path;
        default = [ ];
        example = [ /etc/renovate/environment.env ];
        description = lib.mdDoc ''
          Set environment files for renovate.
        '';
      };

      path = lib.mkOption {
        type = lib.types.listOf lib.types.packages;
        default = [ ];
        example = [ "pkgs.poetry" ];
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
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.renovate = {
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Renovate Service";
      path = cfg.path;
      environment = { RENOVATE_CONFIG_FILE = settingsFile };
      serviceConfig = {
        DynamicUser = true;
        environmentFile = cfg.environmentFiles;
        ExecStart = "${pkgs.renovate}/bin/renovate";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 15;
      };
    };
  };
}
