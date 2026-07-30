# dotfiles

Scripts and configs to set up a new macOS dev machine end to end: install
every CLI tool and app I use, then link my shell/terminal/editor configs.
Everything here is idempotent - re-running `install.sh` on a machine that
already has some (or all) of this installed just skips what's already there.

## Usage

On a fresh Mac:

```sh
git clone https://github.com/muliswilliam/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./install.sh
```

This will, in order:

1. Install Xcode Command Line Tools (skipped if already present; triggers a
   system dialog - click Install - if not).
2. Install Homebrew (skipped if already present).
3. `brew bundle install --no-upgrade --file=Brewfile` - installs every
   formula/cask below (skipped per-item if already installed; never upgrades
   an already-installed one - see note below).
4. Install nvm, an LTS Node, and enable pnpm/yarn via Corepack.
5. Install oh-my-zsh, Powerlevel10k, and the zsh plugins referenced in
   `config/zshrc`.
6. Install the tmux plugin manager (tpm).
7. Install the Claude Code CLI.
8. Symlink dotfiles from `config/` into `$HOME` (backing up any existing
   real file to `<name>.bak` first).
9. Install VS Code extensions and copy `vscode/settings.json`, if the `code`
   CLI is on PATH.

Each step also lives in its own script under `scripts/` if you want to
re-run just one of them.

## Keeping machines in sync

When you fix or change something here, pull it onto every other machine with:

```sh
~/projects/dotfiles/update.sh
```

This does a `git pull --ff-only` then re-runs `install.sh`. Since every step
is idempotent, this is safe to run anytime, on any machine - it only acts on
whatever actually changed (a new Brewfile entry, a new script, an edited
config), and no-ops on everything else. Config files under `config/` are
symlinked into `$HOME`, so a `git pull` alone already updates their live
content; `update.sh` additionally re-runs `brew bundle` and the install
scripts to pick up anything new.

## What's installed

**Brewfile** (installed by default) - CLI tools (git, gh, tmux, ripgrep,
neovim, lazygit, docker, go, python, supabase, ...), terminals (WezTerm,
iTerm2, Warp, Ghostty), editors (VS Code), and apps (Claude Desktop, Docker
Desktop, UTM, BetterDisplay, Postman, TablePlus, 1Password, Bitwarden,
Brave, Microsoft Teams, Slack, Notion, Signal, Stats).

**Brewfile.extra** (not installed by default - see below) - large,
occasionally-used tools: azure-cli, elixir (+ erlang), qemu, ffmpeg (+ its
codec dependency tree), temporal, k6. Install on demand with:

```sh
brew bundle install --no-upgrade --file=Brewfile.extra
```

**Not in either Brewfile** (installed separately, see `scripts/`):
- Node/pnpm - via nvm + Corepack, not Homebrew's `node` formula, so version
  switching keeps working the way it already does on this machine.
- Claude Code CLI - via the official installer script.

`brew bundle install` is called with `--no-upgrade`: it only installs what's
missing and never silently upgrades an already-installed package. Without
this flag, `brew bundle` upgrades any outdated formula/cask it finds in the
Brewfile by default, which on a machine with a lot of history can mean
dozens of unplanned upgrades (each a real download/build) before anything
new actually shows up - looks like the script is stuck, but it's silently
rebuilding things you didn't ask it to touch. Run `brew upgrade` yourself
when you actually want that.

## Dotfiles

`config/` holds the source of truth; `scripts/link-dotfiles.sh` symlinks
each into `$HOME`:

| File | Links to | Purpose |
|---|---|---|
| `zshrc` | `~/.zshrc` | oh-my-zsh + Powerlevel10k shell config |
| `zprofile` | `~/.zprofile` | Homebrew shellenv |
| `tmux.conf` | `~/.tmux.conf` | tmux config (prefix `C-a`, vi copy-mode, Kanagawa theme) |
| `wezterm.lua` | `~/.wezterm.lua` | WezTerm config - primary terminal |
| `p10k.zsh` | `~/.p10k.zsh` | Powerlevel10k prompt config |
| `gitconfig` | `~/.gitconfig` | git user/name and core settings |
| `aerospace.toml` | `~/.config/aerospace/aerospace.toml` | AeroSpace tiling window manager config |

iTerm2, Warp, and Ghostty are installed (see Brewfile) as alternates but
their configs aren't tracked here yet - WezTerm is the primary terminal.

### Secrets

`config/zshrc` sources `~/.zshrc.local` if it exists, which is gitignored
and never committed. `config/zshrc.local.example` is the template -
`link-dotfiles.sh` copies it to `~/.zshrc.local` on first run if that file
doesn't already exist. Put API keys (Anthropic, Gemini, etc.) there, not in
`config/zshrc`.

## VS Code

`vscode/extensions.txt` is the output of `code --list-extensions`;
`vscode/settings.json` is a copy of `Code/User/settings.json`. Regenerate
either with:

```sh
code --list-extensions > vscode/extensions.txt
cp "$HOME/Library/Application Support/Code/User/settings.json" vscode/settings.json
```

`Code/User/mcp.json` is deliberately not tracked here since it can contain
tokens.

## Updating this repo from the current machine

After changing a config or installing something new:

```sh
cp ~/.zshrc config/zshrc          # then re-remove any secrets before committing
cp ~/.tmux.conf config/tmux.conf
cp ~/.wezterm.lua config/wezterm.lua
brew bundle dump --file=Brewfile --force   # regenerates Brewfile from what's installed
```

## Known caveat

A few casks (`docker`, `claude`, `utm`, `betterdisplay`) may already be
installed manually (not via Homebrew) on a given machine. If `brew bundle`
errors with "already installed", either delete the existing app first or
adopt it with `brew install --cask <name> --force`.
