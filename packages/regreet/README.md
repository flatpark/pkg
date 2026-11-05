# regreet

[ReGreet](https://github.com/rharish101/ReGreet): a clean, customizable GTK 4
greeter for [greetd](https://sr.ht/~kennylevinsen/greetd/), usually run in the
cage kiosk compositor.

## Install

```sh
sudo apt install regreet cage
```

Installing does **not** change `/etc/greetd/config.toml`. Switch greetd over
by hand (keep another VT or SSH open in case the greeter fails to start):

```toml
[default_session]
user = "_greetd"
command = "cage -s -mlast -- regreet"
```

```sh
sudo systemctl restart greetd
```

Optional configuration: `/etc/greetd/regreet.toml` (start from
`/usr/share/doc/regreet/examples/regreet.sample.toml`) and
`/etc/greetd/regreet.css`. Logs go to `/var/log/regreet/log`.

## Packaging notes

- Built from the upstream tag (bare `x.y.z`, no `v`) with every crate
  vendored, via `scripts/cargo/fetch-tag.sh`.
- Compile-time paths: config `/etc/greetd`, state `/var/lib/regreet`, logs
  `/var/log/regreet`; reboot/poweroff via `systemctl` (logind).
- Runs as Debian greetd's `_greetd` account: the tmpfiles snippet
  (`/usr/lib/tmpfiles.d/regreet.conf`) gives it the state and log
  directories, where upstream's names a `greeter` user.
- Background images are decoded by glycin (`glycin-loaders`, `bubblewrap`,
  recommended).
- Version bumps wait for review (`"automerge": false`).
