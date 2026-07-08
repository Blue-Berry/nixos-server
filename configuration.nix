{
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.firewall.enable = true;
  networking = {
    hostName = "server";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
    search = ["host-ww.net"];

    interfaces.eth0.ipv4.addresses = [
      {
        address = "169.239.182.193";
        prefixLength = 24;
      }
    ];

    defaultGateway = {
      address = "169.239.182.1";
      interface = "eth0";
    };
  };

  services.openssh.enable = true;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "syncthing";
    group = "media";
    dataDir = "/var/lib/syncthing";

    settings = {
      gui = {
        address = "127.0.0.1:8384";
        user = "admin";
        theme = "black";
      };

      devices = {
        phone.id = "7FACKTB-VRXUUBY-62KQYCB-XUSHLG2-7UGUEDP-O2DXFOF-LCG67E5-TCFNOAO";
        personal.id = "EAQAYXJ-XQMSQRB-F4FCS5Q-W7AC2LO-S7EBTFK-EHWSU5O-LAN5RBC-5CXP5AC";
        iPad.id = "OMHQ3OT-D4PW3LQ-5A75Z4K-4I6OUMM-YGKIQCV-IKPEJJC-7FR6TUR-CUL5EQZ";
        work.id = "R6KDI5U-O4CUY7L-IATHVCY-MIDKOJR-MSLFJVT-VE6HTMN-JDALETZ-AX4SRQC";
      };

      folders = {
        Documents = {
          path = "/var/lib/syncthing/Documents";
          devices = [
            "phone"
            "personal"
            "iPad"
          ];
          ignorePerms = false;
        };

        library = {
          path = "/var/lib/syncthing/library";
          devices = [
            "phone"
            "personal"
            "iPad"
          ];
          ignorePerms = false;
        };
      };
    };
  };

  services.calibre-server = {
    enable = true;
    libraries = ["/var/lib/syncthing/library"];
    openFirewall = true;
    port = 8080;
    user = "calibre-server";
    group = "media";
    host = "0.0.0.0";
    auth = {
      enable = true;
      mode = "basic";
      userDb = "/var/lib/calibre-server/users.sqlite";
    };
  };

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = "/root/miniflux-admin-credentials";
    config = {
      LISTEN_ADDR = "0.0.0.0:8081";
    };
  };

  # Ensure files created by either service are group-writable for the shared group.
  systemd.services.syncthing.serviceConfig.UMask = "0002";
  systemd.services.calibre-server.serviceConfig.UMask = "0002";

  networking.firewall.allowedTCPPorts = [8081];

  services.duckdns = {
    enable = true;
    domains = ["yggdra"]; # yggdra.duckdns.org
    tokenFile = "/root/duckdns-token";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/miniflux 0770 miniflux miniflux - -"
    "d /var/lib/syncthing 0750 syncthing media - -"
    "d /var/lib/syncthing/library 2770 syncthing media - -"
    "d /var/lib/calibre-server 0750 calibre-server media - -"
  ];

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  # Shared group used by Syncthing and Calibre to access /var/lib/syncthing/library.
  users.groups.media = {};

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApCooLFWxg2nQbRFImnxOBdp5QfsNc+qZ138utzcD5Z liamandberry@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDF4Np5JlKC3AKJ2d+c3XN7i8KI+Yk/29gDBTAUly20T liamandberry@gmail.com"
  ];

  environment.enableAllTerminfo = true;
  system.stateVersion = "24.05";
}
