# sysc-greet

[sysc-greet](https://github.com/Nomadcxx/sysc-greet): a terminal-style
greeter for [greetd](https://sr.ht/~kennylevinsen/greetd/) with ASCII art,
animated backgrounds and themes. It runs fullscreen in kitty inside a small
Wayland compositor (sway, Hyprland 0.55+, niri or cagebreak).

## Install

```sh
sudo apt install sysc-greet
```

Installing does **not** change `/etc/greetd/config.toml`. Switch greetd over
by hand (keep another VT or SSH open in case the greeter fails to start):

```toml
[default_session]
user = "_greetd"
# Hyprland 0.55+
command = "start-hyprland -- --config /etc/greetd/hyprland-greeter-config.lua"
# or: command = "sway -c /etc/greetd/sway-greeter-config"
```

```sh
sudo systemctl restart greetd
```

Revert by restoring the previous `command` and `user`.

## Packaging notes

- Built from the upstream tag `v<version>` with Go modules vendored in
  `fetch.sh`; static binary (`CGO_ENABLED=0`), as upstream releases it.
- Upstream's `.deb` installs to `/usr/local/bin`, creates the account, writes
  `config.toml` and enables greetd from its postinst. This package installs to
  `/usr/bin`, rewrites the configs to match, and creates no account: the
  greeter runs as Debian greetd's `_greetd` (configs use
  `HOME=/var/lib/greetd`; subdirectories from
  `/usr/lib/tmpfiles.d/sysc-greet.conf`). Device access comes from the logind
  greeter session, not from `video`/`render`/`input` groups.
- Configs in `/etc/greetd/` (conffiles): `kitty.conf`, `sway-greeter-config`,
  `hyprland-greeter-config.lua`, `niri-greeter-config.kdl`,
  `cagebreak-greeter-config`. Mango and the legacy Hyprland config are left out.
- kitty uses JetBrains Mono (`fonts-jetbrains-mono`) instead of the Nerd Font
  upstream names, which Debian does not ship.
- Wallpapers need gSlapper, not in Debian; without it only the ASCII
  backgrounds show.
- The polkit rule allowing reboot/shutdown for `_greetd` is installed as
  `/usr/share/polkit-1/rules.d/85-sysc-greet.rules`.
- Version bumps wait for review (`"automerge": false`).
