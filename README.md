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

The bmp-from-txt browser renderer is served through Caddy at
<https://yggdra.duckdns.org/bmp-from-txt/>. Its application service listens only on
`127.0.0.1:8086`.

The Miniflux admin credentials file is not committed. Create it on the server at
`/var/lib/miniflux/admin-credentials` before first start.
