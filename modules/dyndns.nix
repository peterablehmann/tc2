{
  inputs,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [ jq ];
  sops.secrets."environment/apitoken" = {
    sopsFile = "${inputs.self}/secrets/environment.yaml";
  };
  sops.secrets."environment/zoneid" = {
    sopsFile = "${inputs.self}/secrets/environment.yaml";
  };
  sops.secrets."environment/recordid" = {
    sopsFile = "${inputs.self}/secrets/environment.yaml";
  };
  
  systemd.timers."dyndns" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
      Unit = "dyndns.service";
    };
  };

  systemd.services."dyndns" = {
    script = ''
      OWN_IP=$(${pkgs.iproute2}/bin/ip -6 a | grep "scope global dynamic mngtmpaddr noprefixroute" | grep "2003:" | cut -d " " -f 6 | sed 's/.\{3\}$//')
      DNS_IP=$(${pkgs.curl}/bin/curl -s "https://dns.hetzner.com/api/v1/records/$(cat ${config.sops.secrets."environment/recordid".path})" -H "Auth-API-Token: $(cat ${config.sops.secrets."environment/apitoken".path})" | ${pkgs.jq}/bin/jq ".record.value" | tr -d '"')
      echo "Current IP: $OWN_IP"
      echo "DNS IP: $DNS_IP"

      [ $OWN_IP = $DNS_IP ] && echo "Already up to date" || ${pkgs.curl}/bin/curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/$(cat ${config.sops.secrets."environment/recordid".path})" -H 'Content-Type: application/json' -H "Auth-API-Token: $(cat ${config.sops.secrets."environment/apitoken".path})" -d $'{"value": "'$OWN_IP'", "ttl": 60, "type": "AAAA", "name": "'$HOSTNAME'", "zone_id": "'$(cat ${config.sops.secrets."environment/zoneid".path})'"}'
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
