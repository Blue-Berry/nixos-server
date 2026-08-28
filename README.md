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
`/root/miniflux-admin-credentials` before first start.

The Miniflux email client runs daily at 08:00. Create
`/root/miniflux-email-client.env` on the server with mode `0600`:

```dotenv
MINIFLUX_TOKEN=your-miniflux-api-token
SMTP_USERNAME=your-smtp-username
SMTP_PASSWORD=your-smtp-password
SEND_TO=you@example.com
```

Optional variables include `SMTP_SERVER`, `SMTP_PORT`, `SEND_FROM`, `CATEGORY`,
and `LIMIT`. Run it immediately with
`systemctl start podman-miniflux-email-client.service`.
