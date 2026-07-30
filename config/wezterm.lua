-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- === Font ===
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 15

-- === Chrome ===
-- tmux owns window/pane chrome (status bar, splits, tabs), so wezterm's own
-- tab bar just duplicates it and eats vertical space -- keep it off.
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt" -- tmux-resurrect/continuum already persist sessions
config.native_macos_fullscreen_mode = true -- play nicely with macOS Spaces/Mission Control

-- Subtle translucency; purely cosmetic, set opacity to 1 to disable.
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

-- === Colors: Synthwave Everything ===
-- https://cmuxthemes.com/themes/synthwave-everything/
--
-- Defined inline rather than via config.color_scheme so the exact hexes live in
-- one place and can be mirrored by the hand-rolled tmux status bar in
-- ~/.tmux.conf -- terminal and multiplexer read as one surface.
--
-- The 16 ANSI slots are the real interface here: powerlevel10k's rainbow prompt
-- and most CLI tools colour themselves by ANSI index, so these slots re-theme
-- the prompt, ls, git, fzf and friends for free.
--
-- Two deliberate departures from the published palette, which ships slots 0 and
-- 8 as #fefefe (it's a VS Code port, so the greyscale slots were never mapped):
-- anything drawing dark-on-colour via `fg=0` renders white-on-mint or
-- white-on-yellow and becomes unreadable -- p10k's rainbow prompt does exactly
-- that on the git and command-duration segments. So slot 0 is a dark plum and
-- slot 8 is #848bbd, Synthwave '84's own comment colour. All 14 other slots are
-- verbatim, including the theme's signature quirk of a *pink* cyan slot with the
-- real cyan parked in bright blue.
config.colors = {
	foreground = "#f0eff1",
	background = "#2a2139",

	cursor_bg = "#72f1b8", -- mint: the one colour the status bar never uses, so the caret always wins
	cursor_border = "#72f1b8",
	cursor_fg = "#2a2139",

	selection_bg = "#463465",
	selection_fg = "#f0eff1",

	--        black      red        green      yellow     blue       magenta    cyan       white
	ansi = { "#241b2f", "#f97e72", "#72f1b8", "#fede5d", "#6d77b3", "#c792ea", "#f772e0", "#fefefe" },
	brights = { "#848bbd", "#f88414", "#72f1b8", "#fff951", "#36f9f6", "#e1acff", "#f92aad", "#fefefe" },
}

-- Previous custom scheme, kept here in case you want to switch back:
-- config.colors = {
-- 	foreground = "#CBE0F0",
-- 	background = "#011423",
-- 	cursor_bg = "#47FF9C",
-- 	cursor_border = "#47FF9C",
-- 	cursor_fg = "#011423",
-- 	selection_bg = "#033259",
-- 	selection_fg = "#CBE0F0",
-- 	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
-- 	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
-- }
-- Or the muted Kanagawa this replaced:
-- config.color_scheme = "Kanagawa (Gogh)"

-- === tmux integration (disabled for now) ===
-- Auto-attaches every new WezTerm window/tab to a persistent "main" tmux
-- session, creating it if it doesn't exist yet. Combined with
-- tmux-resurrect/continuum this means panes/layout/running commands survive
-- quitting WezTerm or rebooting. Revisit later -- uncomment to re-enable.
--
-- Absolute path is required here: default_prog execs the argv directly
-- rather than going through a login shell, so it only sees macOS's bare
-- PATH (/usr/bin:/bin:/usr/sbin:/sbin), which doesn't include Homebrew's
-- /opt/homebrew/bin.
-- config.default_prog = { "/opt/homebrew/bin/tmux", "new-session", "-A", "-s", "main" }

-- Scrollback here only matters for the rare pane running outside tmux
-- (tmux's own `history-limit 50000` governs scrollback inside sessions).
config.scrollback_lines = 10000

-- Leave WezTerm's own leader/pane keys untouched and don't bind CMD to
-- splits/panes: tmux (prefix C-a, `|`/`-` splits, vim-tmux-navigator for
-- Ctrl-hjkl movement) is the single source of truth for multiplexing, so
-- there's exactly one set of muscle memory to learn.

config.keys = {
	-- Native macOS fullscreen toggle
	{ key = "Enter", mods = "CMD", action = act.ToggleFullScreen },
}

-- === Agent-attention notifications ===
-- Fires on any BEL (0x07), including ones tmux forwards from a background
-- window (see `bell-action any` in ~/.tmux.conf). Pops a native macOS
-- notification so you notice even when WezTerm isn't focused -- this is how
-- Claude Code/Codex CLI etc. can tell you they need input from inside a
-- tmux pane.
wezterm.on("bell", function(window, pane)
	window:toast_notification("Agent needs input", pane:get_title(), nil, 4000)
end)

-- and finally, return the configuration to wezterm
return config
