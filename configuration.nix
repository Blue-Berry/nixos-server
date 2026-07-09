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

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  nix.optimise.automatic = true;

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

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "media";
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
            "work"
          ];
          ignorePerms = false;
        };

        library = {
          path = "/var/lib/syncthing/library";
          devices = [
            "phone"
            "personal"
            "iPad"
            "work"
          ];
          ignorePerms = false;
        };

        Audiobooks = {
          path = "/var/lib/syncthing/audiobooks";
          devices = [
            "phone"
            "personal"
            "iPad"
            "work"
          ];
          ignorePerms = false;
        };
      };
    };
  };

  services.calibre-server = {
    enable = true;
    libraries = ["/var/lib/syncthing/library"];
    port = 8080;
    openFirewall = false;
    user = "media";
    group = "media";
    host = "127.0.0.1";
    auth = {
      enable = true;
      mode = "basic";
      userDb = "/var/lib/calibre-server/users.sqlite";
    };
  };

  services.calibre-web = {
    enable = true;
    user = "media";
    group = "media";
    listen = {
      ip = "127.0.0.1";
      port = 8081;
    };
    openFirewall = false;
    options = {
      calibreLibrary = "/var/lib/syncthing/library";
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };

  services.audiobookshelf = {
    enable = true;
    user = "media";
    group = "media";
    host = "127.0.0.1";
    port = 8082;
    openFirewall = false;
  };

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = "/root/miniflux-admin-credentials";
    config = {
      LISTEN_ADDR = "127.0.0.1:8083";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "yggdra-calibre.duckdns.org".extraConfig = ''
        reverse_proxy localhost:8081
      '';
      "yggdra-opds.duckdns.org".extraConfig = ''
        reverse_proxy localhost:8080
      '';
      "yggdra-rss.duckdns.org".extraConfig = ''
        reverse_proxy localhost:8083
      '';
      "yggdra-audio.duckdns.org".extraConfig = ''
        reverse_proxy localhost:8082
      '';
    };
  };

  services.duckdns = {
    enable = true;
    domains = [
      "yggdra"
      "yggdra-opds"
      "yggdra-calibre"
      "yggdra-rss"
      "yggdra-audio"
    ]; # yggdra.duckdns.org
    tokenFile = "/root/duckdns-token";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/miniflux 0770 miniflux miniflux - -"
    "d /var/lib/syncthing 0750 media media - -"
    "d /var/lib/syncthing/library 2770 media media - -"
    "d /var/lib/syncthing/audiobooks 2770 media media - -"
    "d /var/lib/calibre-server 0750 media media - -"
  ];

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.media = {
    isSystemUser = true;
    group = "media";
  };
  users.groups.media = {};

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApCooLFWxg2nQbRFImnxOBdp5QfsNc+qZ138utzcD5Z liamandberry@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDF4Np5JlKC3AKJ2d+c3XN7i8KI+Yk/29gDBTAUly20T liamandberry@gmail.com"
  ];

  environment.enableAllTerminfo = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:Blue-Berry/nixos-server#server";
    allowReboot = false;
    dates = "04:00";
    randomizedDelaySec = "45min";
  };

  system.stateVersion = "24.05";
}
