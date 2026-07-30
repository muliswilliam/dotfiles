# Homebrew Bundle file. `brew bundle` is idempotent by default: it skips
# anything already installed, so this file is safe to re-run on this machine
# or run fresh on a new one.
#
# Install everything:   brew bundle install --file=Brewfile
# Check what's missing: brew bundle check --file=Brewfile --verbose

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
brew "qemu"

# --- Languages / toolchains ---
brew "node@20"
brew "node@22"
brew "go"
brew "elixir"
brew "python@3.12"
brew "python@3.13"

# --- Cloud / backend tooling ---
brew "azure-cli"
brew "supabase"
brew "golang-migrate"
brew "goose"
brew "golangci-lint"
brew "libpq"
brew "temporal"
brew "mkcert"
brew "cloudflared"

# --- Networking / diagnostics ---
brew "nmap"
brew "iperf3"
brew "speedtest-cli"
brew "k6"

# --- Misc dev utilities ---
brew "cmake"
brew "graphviz"
brew "glow"               # markdown viewer in terminal
brew "ffmpeg"

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
cask "goland"
cask "intellij-idea-ce"
cask "webstorm"

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
