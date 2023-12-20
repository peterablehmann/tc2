{ modulesPath, lib, inputs, config, ... }: {
  imports = [

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
    ./modules
    ./renovate/renovate.nix
  ];

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "de_DE.UTF-8";

  boot.tmp.cleanOnBoot = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  networking = {
    usePredictableInterfaceNames = lib.mkDefault false;
    hostName = "tc2";
    domain = "xnee.net";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
    };
    interfaces.eth0.useDHCP = true;
  };

  sops.secrets."renovate/environment" = {
    sopsFile = "${inputs.self}/secrets/renovate.yaml";
  };

  services.renovate = {
    enable = true;
    environmentFiles = [ config.sops.secrets."renovate/environment".path ];
    settings = {
      repositories = [
        "peterablehmann/terraform"
        "peterablehmann/flake"
        "peterablehmann/tc1"
        "peterablehmann/tc2"
        ];
    };
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1Ss4ebDys/jMEzTPTv3/h9uRly37034XKQ79w9y7Yf xgwq@kee"
    ];
  };

  system.stateVersion = "23.05";
}
