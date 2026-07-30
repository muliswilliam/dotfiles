# Homebrew Bundle file - core, always-installed tools. `brew bundle` is
# idempotent by default: it skips anything already installed, so this file
# is safe to re-run on this machine or run fresh on a new one.
#
# Install everything:   brew bundle install --no-upgrade --file=Brewfile
# Check what's missing: brew bundle check --file=Brewfile --verbose
#
# Large, occasionally-used tools (azure-cli, elixir/erlang, qemu, ffmpeg,
# temporal, k6) live in Brewfile.extra instead, so a fresh machine setup
# doesn't pull them in by default. See README for how to install those.

# --- Taps ---
tap "homebrew/bundle"
tap "nikitabobko/tap"    # AeroSpace lives here, not in homebrew/cask

# --- Core CLI tools ---
brew "coreutils"
brew "gh"                # GitHub CLI
brew "git"
brew "gnupg"
brew "htop"
brew "tmux"
brew "tree"
brew "unzip"
brew "watchman"
brew "ripgrep"
brew "fd"
brew "neovim"
brew "lazygit"

# --- Containers / infra ---
brew "docker"
brew "docker-compose"
brew "podman"

# --- Languages / toolchains ---
brew "go"
brew "python@3.14"

# --- Cloud / backend tooling ---
brew "supabase"
brew "golang-migrate"
brew "goose"
brew "golangci-lint"
brew "libpq"
brew "mkcert"
brew "cloudflared"

# --- Networking / diagnostics ---
brew "nmap"
brew "iperf3"
brew "speedtest-cli"

# --- Misc dev utilities ---
brew "cmake"
brew "graphviz"
brew "glow"               # markdown viewer in terminal

# --- Fonts (needed for Powerlevel10k / Nerd Font terminal icons) ---
cask "font-jetbrains-mono-nerd-font"
cask "font-meslo-lg-nerd-font"

# --- Terminals ---
cask "wezterm"            # primary terminal - see config/wezterm.lua
cask "iterm2"
cask "warp"
cask "ghostty"

# --- Editors / IDEs ---
cask "visual-studio-code"

# --- AI coding tools ---
cask "claude"             # Claude Desktop (Claude Code is installed via scripts/install-claude-code.sh)

# --- Dev-adjacent apps ---
cask "docker"             # Docker Desktop GUI (see note in README if this errors as "already installed")
cask "utm"
cask "betterdisplay"
cask "postman"
cask "tableplus"
cask "dbngin"
cask "db-browser-for-sqlite"
cask "mitmproxy"
cask "1password"
cask "bitwarden"
cask "nikitabobko/tap/aerospace"
cask "opensuperwhisper"  # voice dictation

# --- Communication / productivity ---
cask "brave-browser"
cask "microsoft-teams"
cask "slack"
cask "notion"
cask "signal"
