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
    dataDir = "/var/lib/syncthing";

    settings = {
      gui = {
        address = "127.0.0.1:8384";
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
    openFirewall = false;
    port = 8080;
    user = "syncthing";
    group = "syncthing";
    host = "127.0.0.1";
  };

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = "/var/lib/miniflux/admin-credentials";
    config = {
      LISTEN_ADDR = "127.0.0.1:8081";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/miniflux 0750 miniflux miniflux - -"
  ];

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApCooLFWxg2nQbRFImnxOBdp5QfsNc+qZ138utzcD5Z liamandberry@gmail.com"
  ];

  system.stateVersion = "24.05";
}
