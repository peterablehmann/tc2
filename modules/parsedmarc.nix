{ config,
  pkgs,
  inputs,
  ...
}:
{
  sops.secrets."mail/password" = {
    neededForUsers = true;
    sopsFile = "${inputs.self}/secrets/parsedmarc.yaml";
  };
  sops.secrets."maxmind/licensekey" = {
    neededForUsers = true;
    sopsFile = "${inputs.self}/secrets/parsedmarc.yaml";
  };

  services = {
    parsedmarc = {
      enable = true;
      settings = {
        imap = {
          host = "mail.your-server.de";
          port = 993;
          ssl = true;
          user = "dmarc@xnee.net";
          password = config.sops.secrets."mail/password".path;
        };
      };
    };
    geoipupdate.settings = {
      AccountID = 934098;
      LicenseKey = config.sops.secrets."maxmind/licensekey".path;
    };
  };
}
