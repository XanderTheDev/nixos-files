{ config, pkgs, inputs, lib, ... }:

{
        systemd.services.cups.serviceConfig = {
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          NoNewPrivileges = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          RestrictNamespaces = true;
          ReadWritePaths = [ "/etc/cups" "/var/spool/cups" "/var/cache/cups" ];
        };

        systemd.services."NetworkManager-dispatcher".serviceConfig = {
          NoNewPrivileges = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectClock = true;
          ProtectHostname = true;
          LockPersonality = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          MemoryDenyWriteExecute = true;
          ProtectControlGroups = true;
          SystemCallArchitectures = "native";
          UMask = "0077";
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ "/etc/resolv.conf" ];
        };
        
        systemd.services.auto-cpufreq.serviceConfig = {
          ProtectHome = true;
          ProtectSystem = "strict";
          PrivateTmp = true;
          ProtectKernelLogs = true;
          RestrictNamespaces = true;
          ReadWritePaths = [ "/var/run/auto-cpufreq.stats" ];
        };

        security.pki.certificateFiles = [ ../caddy-root.crt ];
}
