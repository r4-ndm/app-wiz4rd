# 😈 app-wiz4rd

The Syntropia "pick your favorite apps" wizard, standalone edition.

A full-width `fzf` picker (with a 5-line slant `SYNTROPIA` banner, coloured
category tags, package names, and adaptive description/alias columns) that
installs whatever you check in a single `paru -S` transaction — official-repo
and AUR packages alike. When `fzf` is not installed, it degrades gracefully to
a numbered-list prompt. The catalog is a plain text file, so adding an app is a
one-line edit.

## Install

From the AUR:

```bash
paru -S app-wiz4rd
```

Or run straight from a checkout:

```bash
./app-wiz4rd
```

## What it does

- Opens a full-width `fzf` picker (`--no-preview`, rounded border) with the
  centred 5-line slant `SYNTROPIA` banner at the top and a three-column list:
  256-colour category (`%-10s`), bold package name (`%-26s`), and a description
  column truncated adaptively to terminal width (`desc_w = width - 44`, floor
  20) plus an optional dimmed `(aliases)` suffix so aliases stay searchable
  (`SPACE` tick, `ENTER` install, `ESC` cancel, type to filter).
- **Numbered fallback**: if `fzf` is not installed (or `SYNTROPIA_PICKER_NO_FZF=1`
  is set), falls back to a numbered list on stderr where you type space-separated
  numbers (e.g. `1 4 7`) to select apps.
- Installs all picks in one `paru -S --noconfirm --needed` transaction with
  live output, teed to `~/.local/state/app-wiz4rd/install.log` so the output
  survives the window closing
- **Web apps** (an `https://` package line) get a PWA-style desktop launcher
  instead — no install needed
- **Local helpers** (a `syntropia-<name>` package field that exists as an
  executable in `/usr/local/bin`, or `$SYNTROPIA_BIN_DIR`) run directly as
  local helper commands before the `paru` batch, with output teed to
  `install.log` and each helper unqueued on success
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

Starting the picker without a connection offers NetworkManager's own UI
(`nmtui-connect`) first, so the common case — first boot before Wi-Fi is
joined — installs immediately instead of queueing everything:

```
😈 No internet connection.
   [1] Connect now (NetworkManager text UI)
   [2] Continue — picks are saved and installed once you are online
   Choose [1-2] (default: 1):
```

Picking with no connection loses nothing:

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
category|display name|package|short description[|aliases]
```

- `package` = pacman repo **or** AUR package name (paru resolves either),
  an `https://` URL for a web app, or a `syntropia-<name>` command that exists
  in `/usr/local/bin` (run as a local helper before the `paru` batch, each
  unqueued on success; if not executable in `/usr/local/bin`, it stays in the
  `paru` batch as a normal package)
- Optional 5th field (`aliases`, e.g. `bw bitwig daw`) is rendered as a dimmed
  suffix `(bw bitwig daw)` so abbreviations and alternate keywords stay
  searchable in `fzf`
- Copy it to `~/.config/syntropia/apps.list` and edit to make it yours — the
  wizard prefers the user copy over the bundled one
- New category = just use a new category name on the line

## Layout

```
app-wiz4rd              the driver script (/usr/bin/app-wiz4rd when packaged)
apps.list               the app catalog
syntropia-apps.desktop  autostart template (used by --install-autostart)
app-wiz4rd.desktop      app-menu launcher
dialog/main.go          legacy Go TUI source (no longer used at runtime)
aur/                    the AUR packaging (PKGBUILD, .SRCINFO)
```

## Requirements

- `fzf` is the only runtime dependency of the interactive full-width picker (if
  `fzf` is missing, the script automatically falls back to a numbered prompt;
  the Go TUI is no longer used)
- `paru` is only needed when there is something native to install; missing
  paru offline simply keeps the queue for later
- Arch-based system (CachyOS, Arch, EndeavourOS…) with `paru` — the wizard
  bootstraps it if missing (it installs paru from the official repos itself)

## License

MIT — see `LICENSE`.
