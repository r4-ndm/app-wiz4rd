# 😈 app-wiz4rd

The Syntropia "pick your favorite apps" wizard, standalone edition.

One grouped checkbox TUI (Bubble Tea / Charm ecosystem) that installs
whatever you check in a single `paru -S` transaction — official-repo and AUR
packages alike. The catalog is a plain text file, so adding an app is a
one-line edit.

## Install

From the AUR:

```bash
paru -S app-wiz4rd
```

Or run straight from a checkout (builds the TUI on demand if `go` is
installed):

```bash
./app-wiz4rd
```

Or grab the **zero-install tarball** from the latest GitHub release —
the prebuilt static TUI is bundled, so no Go and no AUR helper is
needed:

```bash
curl -LO https://github.com/r4-ndm/app-wiz4rd/releases/latest/download/app-wiz4rd-0.1.0-x86_64.tar.gz
tar -xzf app-wiz4rd-0.1.0-x86_64.tar.gz
cd app-wiz4rd-0.1.0
./app-wiz4rd
```

## What it does

- Shows your catalog as a keyboard-first checkbox grid (`↑/↓`/`jk` move,
  `←/→` between columns, `space` toggle, `a` all, `n` none, `space` on DONE
  arms it, `enter` installs, `esc` cancels)
- Installs all picks in one `paru -S --noconfirm` transaction with live output
- **Web apps** (an `https://` package line) get a PWA-style desktop launcher
  instead — no install needed
- Every pick is written to a **pending queue**
  (`~/.config/syntropia/apps-wizard.pending`) *before* `paru` runs, and only
  packages that really installed leave it — an offline run loses nothing
- `--once` mode self-disables after a **successful** install (completion
  marker at `~/.config/syntropia/apps-wizard.done`); cancelling never marks
  done, so you can re-run any time. While the queue is non-empty, `--once`
  keeps running on each login until it drains
- `--resume` installs whatever is queued, without opening the picker
- `--install-autostart` / `--remove-autostart` manage a one-shot run on the
  next login

## Offline use

Pick apps with no connection and nothing is lost:

```
😈 No internet right now. You can still pick apps:
   they are saved to a queue and installed next time you are online.
...
Queued 3 choice(s).
😈 paru could not install everything — the picks stay queued, so nothing is lost.

😈 3 app(s) are saved and waiting: ~/.config/syntropia/apps-wizard.pending
   You are offline. Connect, then either log in again or run:
     app-wiz4rd --resume
```

Once the machine is online, any of these finishes the job: logging in
(`--once` retries the queue), opening the wizard from the app menu (it retries
the queue before the picker), or `app-wiz4rd --resume`. Web-app picks only need
a local launcher, so they are created even offline.

## The catalog

`apps.list`, one app per line:

```
category|display name|package|short description
```

- `package` = pacman repo **or** AUR package name (paru resolves either), or
  an `https://` URL for a web app
- Copy it to `~/.config/syntropia/apps.list` and edit to make it yours — the
  wizard prefers the user copy over the bundled one
- New category = just use a new category name on the line

## Layout

```
app-wiz4rd              the driver script (/usr/bin/app-wiz4rd when packaged)
apps.list               the app catalog
syntropia-apps.desktop  autostart template (used by --install-autostart)
app-wiz4rd.desktop      app-menu launcher
dialog/main.go          the TUI source (Bubble Tea; static CGO_ENABLED=0 build)
aur/                    the AUR packaging (PKGBUILD, .SRCINFO)
```

## Requirements

- `paru` is only needed when there is something native to install; missing
  paru offline simply keeps the queue for later

- Arch-based system (CachyOS, Arch, EndeavourOS…) with `paru` — the wizard
  bootstraps it if missing (it installs paru from the official repos itself)
- The TUI is a **static Go binary with zero runtime dependencies**

## License

MIT — see `LICENSE`.
