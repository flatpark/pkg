# honk

[honk](https://github.com/daeuniverse/honk): an experimental eBPF transparent
proxy engine written in Rust. It reads dae's configuration syntax, splits
traffic in the kernel, and embeds the [doona](https://github.com/Zakkaus/doona)
web UI next to a Clash-compatible API. Upstream calls it **early alpha**.

This is the official upstream release `.deb` (`honk-core-v<version>-x86_64.deb`,
the static musl "full" build), repackaged unmodified: `/usr/bin/honk-core`,
`honk-core.service` and `/etc/honk/example.dae` are byte-identical to it. The
package is named `honk-core`, like upstream's.

## Install

```sh
sudo apt install honk-core
```

Needs Linux 6.12+ with BTF, cgroup v2 and bpffs (current sid kernels qualify).

## Set up

Installing does **not** enable or start the service: `honk-core.service` runs
`/etc/honk/config.dae`, which you write first. The config uses dae syntax; see
upstream's [startup guide](https://github.com/daeuniverse/honk/blob/main/doc/en/how-to-start.md)
and [configuration guide](https://github.com/daeuniverse/honk/blob/main/doc/en/configuration.md).

```sh
sudo install -d -m 700 /etc/honk /var/lib/honk
sudo install -m 600 my-config.dae /etc/honk/config.dae
sudo systemctl enable --now honk-core
```

`/etc/honk/example.dae` is upstream's annotated sample (it names interfaces
and nodes of upstream's own lab, so it does not run as is).

**Geo data.** Rules with `geoip:`/`geosite:` need `geoip.dat`/`geosite.dat`,
which this package does not ship and Debian does not package. Put them in the
data directory before the first start:

```sh
sudo curl -fL -o /var/lib/honk/geosite.dat \
  https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
sudo curl -fL -o /var/lib/honk/geoip.dat \
  https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
```

With the native API enabled, honk then refreshes them itself (daily by
default). It also finds the copies of a still-installed `dae` package in
`/usr/share/dae/`.

**Switching from dae.** honk attaches to the same interfaces, so the two never
run together: `honk-core.service` has `Conflicts=dae.service`. Most dae
configs carry over; `-> must_direct` has to become `-> direct(must)`, and
`domain(contains: ...)` has to become `domain(keyword: ...)`. Then:

```sh
sudo systemctl disable --now dae
sudo systemctl enable --now honk-core
```

`systemctl reload honk-core` applies config changes; check the journal for
`applied` or `rejected`.

## Updates

Through apt. Once the service is enabled, a package upgrade restarts it
(briefly interrupting proxied traffic); a disabled, stopped service stays that
way. Removing the package stops and disables it.

The daily update check follows **every** upstream version tag, pre-releases
included (`vX.Y.Z` and `vX.Y.Z-alpha|beta|rc.N`; the rolling `debug*` builds
are skipped). New versions are built and install-tested, but wait for review
(`"automerge": false` in `meta.json`): honk is an alpha network daemon that
restarts on upgrade and still changes configuration between minor versions.
Upstream's `0.1.0-beta.5` is packaged as `0.1.0~beta.5-1`, so the final
`0.1.0` sorts above it.

## Packaging notes

- `meta.json` pins upstream's amd64 `.deb` (URL + sha256); `fetch.sh` verifies
  it and unpacks its data (`dpkg-deb -x`) as the source tree. Upstream's
  control files and maintainer scripts are replaced by `debian/`. Nothing is
  compiled.
- `debian/rules` skips `dh_strip`/`dh_dwz` to keep the binary byte-identical
  and installs the unit with `--no-enable`.
- `smoke.sh` checks `honk-core --version` against the package version and
  starts a direct-only config in `--mock-ebpf` mode, which needs neither root
  datapath nor network hooks.
- Upstream's `.deb` points to doona's third-party notices under
  `/usr/share/doc/honk-core/doona`, but does not contain them; they are in the
  release tarballs (see `debian/copyright`).
