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

## What it does

- Shows your catalog as a keyboard-first checkbox grid (`↑/↓`/`jk` move,
  `←/→` between columns, `space` toggle, `a` all, `n` none, `space` on DONE
  arms it, `enter` installs, `esc` cancels)
- Installs all picks in one `paru -S --noconfirm` transaction with live output
- **Web apps** (an `https://` package line) get a PWA-style desktop launcher
  instead — no install needed
- `--once` mode self-disables after a **successful** install (completion
  marker at `~/.config/syntropia/apps-wizard.done`); cancelling never marks
  done, so you can re-run any time
- `--install-autostart` / `--remove-autostart` manage a one-shot run on the
  next login

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

- Arch-based system (CachyOS, Arch, EndeavourOS…) with `paru` — the wizard
  bootstraps it if missing (it installs paru from the official repos itself)
- The TUI is a **static Go binary with zero runtime dependencies**

## License

MIT — see `LICENSE`.
