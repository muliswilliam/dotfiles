-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- === Font ===
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 14

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

-- tmux (prefix C-a, `|`/`-` splits, vim-tmux-navigator for Ctrl-hjkl) still
-- owns multiplexing *within* a single session -- that muscle memory is
-- untouched here. What WezTerm handles is a level up: tiling several
-- already-running tmux sessions side by side in one window so they can all
-- be watched at once. Splits/navigation below live on Cmd(+Alt) specifically
-- because tmux never sees Cmd, so there's no ambiguity about which layer a
-- keypress belongs to (bare Cmd+H/Cmd+M are skipped since macOS reserves
-- those for Hide/Minimize).

-- Cmd+C copy that's reliable with tmux's mouse mode on: dragging a selection
-- inside tmux (see ~/.tmux.conf `mouse on`) puts the pane into copy-mode via
-- raw mouse reporting rather than WezTerm's own selection, so WezTerm has
-- nothing to copy and its default CopyTo(Clipboard) binding for Cmd+C is a
-- no-op. Route through tmux instead by sending it F13, which ~/.tmux.conf
-- binds to "copy the pending copy-mode selection and exit" -- safe to send
-- unconditionally since it's a no-op outside copy-mode.
--
-- Checking only the foreground process name isn't enough to decide that,
-- though: it's "tmux" any time tmux is the local pty's foreground process,
-- regardless of what's running in the active pane. A plain shell doesn't
-- request mouse reporting, so tmux captures the drag itself and enters
-- copy-mode -- F13 is correct there. But a full-screen program with its own
-- mouse reporting (vim, Claude Code) makes tmux forward the drag to it
-- instead, so copy-mode is never entered and F13 would no-op; in that case
-- WezTerm's native selection (made by holding the bypass modifier -- SHIFT by
-- default -- while dragging, which skips mouse reporting entirely) is what
-- actually has the text, so CopyTo(Clipboard) is what's needed. Query tmux's
-- real copy-mode state to pick between the two rather than assuming it from
-- the process name.
local function copy_selection(window, pane)
	local proc = pane:get_foreground_process_name() or ""
	local in_tmux_copy_mode = false
	if proc:find("tmux") then
		local ok, stdout = wezterm.run_child_process({ "tmux", "display-message", "-p", "#{pane_in_mode}" })
		in_tmux_copy_mode = ok and stdout:match("^1") ~= nil
	end
	if in_tmux_copy_mode then
		window:perform_action(act.SendKey({ key = "F13" }), pane)
	else
		window:perform_action(act.CopyTo("Clipboard"), pane)
	end
end

config.keys = {
	-- Native macOS fullscreen toggle
	{ key = "Enter", mods = "CMD", action = act.ToggleFullScreen },

	-- Drag to select (tmux or native), then Cmd+C to copy -- see copy_selection above.
	{ key = "c", mods = "CMD", action = wezterm.action_callback(copy_selection) },

	-- Split the window to tile another tmux session alongside this one.
	-- Same | / - mnemonic as tmux's own split bindings (vertical bar, horizontal
	-- dash), just on Cmd instead of the tmux prefix.
	{ key = "|", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
	{ key = "-", mods = "CMD", action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },

	-- Move focus between WezTerm panes (each its own tmux session).
	{ key = "h", mods = "CMD|ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CMD|ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CMD|ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CMD|ALT", action = act.ActivatePaneDirection("Down") },

	-- Maximize the focused WezTerm pane (hides the others in this tab, not
	-- tmux's own panes -- press again to restore the split).
	{ key = "Enter", mods = "CMD|ALT", action = act.TogglePaneZoomState },
}

-- tmux's `mouse on` (see ~/.tmux.conf) puts the pane into "mouse reporting"
-- mode, where a binding only fires if its `mouse_reporting` flag matches that
-- state -- so Cmd+click needs two copies here (reporting off/on) to work both
-- inside and outside tmux, and Down needs its own Nop so tmux doesn't act on
-- a down-click that never gets a matching up-click.
--
-- Deliberately NOT adding CMD to `bypass_mouse_reporting_modifiers` (default
-- SHIFT) to force this past tmux instead: WezTerm strips a bypass modifier
-- from the click before matching mouse_bindings, so a bypass modifier that's
-- also a binding's `mods` makes that binding stop matching entirely --
-- https://github.com/wezterm/wezterm/issues/4536.
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = act.Nop,
	},
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CMD",
		mouse_reporting = true,
		action = act.Nop,
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = act.OpenLinkAtMouseCursor,
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		mouse_reporting = true,
		action = act.OpenLinkAtMouseCursor,
	},
}

-- Agent-attention notifications (Claude Code/Codex CLI prompting for input
-- from inside a tmux pane, including background sessions) are handled by a
-- tmux `alert-bell` hook in ~/.tmux.conf, which fires a native macOS
-- notification directly via osascript -- see scripts/tmux-bell-notify.sh.
-- That covers sessions with no attached client, which BEL-forwarding to
-- WezTerm's own bell event (the previous approach here) could not.

-- and finally, return the configuration to wezterm
return config
