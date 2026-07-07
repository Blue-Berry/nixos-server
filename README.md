# Personal Server

Standalone NixOS flake for the personal server.

Build the system closure:

```sh
nix build .#nixosConfigurations.server.config.system.build.toplevel --no-link
```

Switch the remote server:

```sh
nixos-rebuild switch --flake .#server --target-host root@169.239.182.193
```

The Miniflux admin credentials file is not committed. Create it on the server at
`/var/lib/miniflux/admin-credentials` before first start.

The Syncthing GUI password is also not committed. Create it on the server at
`/var/lib/syncthing/syncthing-gui-password`, owned by `syncthing:syncthing` and
mode `0400`.
