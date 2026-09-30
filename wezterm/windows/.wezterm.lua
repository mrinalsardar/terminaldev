-- ~/.wezterm.lua (or %USERPROFILE%\.wezterm.lua on Windows) 
-- 
-- Single-file WezTerm configuration for Windows 11 + PowerShell, 
-- adapted from the structure/feature-set of KevinSilvester/wezterm-config 
-- (https://github.com/KevinSilvester/wezterm-config) but collapsed into 
-- one self-contained file instead of the original's multi-module layout. 
-- 
-- Requires WezTerm >= 20240127-113634-bbcac864 (Nightly recommended). 
-- Recommended font: JetBrainsMono Nerd Font 
-- scoop bucket add nerd-fonts 
-- scoop install JetBrainsMono-NF 

local wezterm = require('wezterm') 
local mux = wezterm.mux 
local act = wezterm.action 

local config = wezterm.config_builder and wezterm.config_builder() or {} 

-------------------------------------------------------------------------- 
-- Key-binding "modifier" scheme 
-- SUPER -> Alt (mirrors the original repo's Windows/Linux mapping) 
-- SUPER_REV -> Alt+Ctrl 
-- LEADER -> SUPER_REV + Space 
-------------------------------------------------------------------------- 
local SUPER = 'ALT' 
local SUPER_REV = 'ALT|CTRL' 

config.leader = { key = 'Space', mods = SUPER_REV, timeout_milliseconds = 1000 } 

---------------------------------------------------------------------------
-- for VDI/old GPU setup where wezterm doesn't open
-- config.front_end = "Software"
------------------------------------------------------------------------- 

-------------------------------------------------------------------------- 
-- Shell / launch menu (Windows 11, PowerShell-first) 
-------------------------------------------------------------------------- 
-- Prefer PowerShell 7 (pwsh) if installed, otherwise fall back to Windows 
-- PowerShell. Adjust the paths below if your install locations differ. 
config.default_prog = { 'powershell.exe', '-NoLogo' } 

config.launch_menu = { 
 { label = 'Windows PowerShell', args = { 'powershell.exe', '-NoLogo' } }, 
 { label = 'Command Prompt', args = { 'cmd.exe' } }, 
 { 
 label = 'WSL - Ubuntu', 
 args = { 'wsl.exe', '~', '-d', 'Ubuntu' }, 
 }, 
} 

-- Optional named domains (edit/uncomment to match `wsl -l -v` output). 
config.wsl_domains = { 
 { 
 name = 'WSL:Ubuntu', 
 distribution = 'Ubuntu', 
 username = 'user', 
 default_cwd = '/home/user', 
 }, 
} 

-------------------------------------------------------------------------- 
-- Fonts 
-------------------------------------------------------------------------- 
-- config.font = wezterm.font_with_fallback({ 
--  { family = 'JetBrainsMono Nerd Font', weight = 'Regular' }, 
--  { family = 'Segoe UI Emoji' }, 
-- }) 
config.font_size = 11.0 
config.line_height = 1.1 
config.underline_thickness = '1.5pt' 
config.adjust_window_size_when_changing_font_size = false 

-------------------------------------------------------------------------- 
-- Appearance 
-------------------------------------------------------------------------- 
config.color_scheme = 'Catppuccin Mocha' 

config.front_end = 'WebGpu' 
config.webgpu_power_preference = 'HighPerformance' 
config.max_fps = 120 
config.animation_fps = 120 

config.default_cursor_style = 'BlinkingBlock' 
config.cursor_blink_rate = 3000 
config.cursor_blink_ease_in = 'EaseOut' 
config.cursor_blink_ease_out = 'EaseOut' 

config.enable_scroll_bar = true 
config.window_close_confirmation = 'AlwaysPrompt' 
config.window_decorations = 'TITLE | RESIZE' 
config.window_padding = { left = 0, right = 0, top = 10, bottom = 7.5 } 
config.window_frame = { active_titlebar_bg = '#090909' } 
config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.75 } 

config.visual_bell = { 
 fade_in_function = 'EaseIn', 
 fade_in_duration_ms = 250, 
 fade_out_function = 'EaseOut', 
 fade_out_duration_ms = 250, 
 target = 'CursorColor', 
} 

config.command_palette_fg_color = '#b4befe' 
config.command_palette_bg_color = '#11111b' 
config.command_palette_font_size = 12 
config.command_palette_rows = 25 

-- Tab bar 
config.enable_tab_bar = true 
config.hide_tab_bar_if_only_one_tab = false 
config.use_fancy_tab_bar = false 
config.tab_max_width = 25 
config.show_tab_index_in_tab_bar = false 
config.switch_to_last_active_tab_when_closing_tab = true 

-------------------------------------------------------------------------- 
-- Tab title formatting (mirrors the numbered/icon style from the source repo) 
-------------------------------------------------------------------------- 
local SOLID_LEFT_ARROW = utf8.char(0xe0b2) 
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0) 

local function tab_title(tab_info) 
 local title = tab_info.tab_title 
 if title and #title > 0 then 
 return title 
 end 
 return tab_info.active_pane.title 
end 

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width) 
 local edge_background = '#0f0f14' 
 local background = '#1e1e2e' 
 local foreground = '#cdd6f4' 

 if tab.is_active then 
 background = '#89b4fa' 
 foreground = '#11111b' 
 elseif hover then 
 background = '#313244' 
 foreground = '#cdd6f4' 
 end 

 local edge_foreground = background 
 local title = tab_title(tab) 
 local index = tab.tab_index + 1 

 title = wezterm.truncate_right(title, max_width - 4) 

 return { 
 { Background = { Color = edge_background } }, 
 { Foreground = { Color = edge_foreground } }, 
 { Text = SOLID_LEFT_ARROW }, 
 { Background = { Color = background } }, 
 { Foreground = { Color = foreground } }, 
 { Text = string.format(' %d: %s ', index, title) }, 
 { Background = { Color = edge_background } }, 
 { Foreground = { Color = edge_foreground } }, 
 { Text = SOLID_RIGHT_ARROW }, 
 } 
end) 

-------------------------------------------------------------------------- 
-- Right-status bar: clock (like the original's right-status event module) 
-------------------------------------------------------------------------- 
wezterm.on('update-status', function(window, pane) 
 local date = wezterm.strftime('%a %H:%M:%S') 
 window:set_right_status(wezterm.format({ 
 { Foreground = { Color = '#b4befe' } }, 
 { Text = ' ' .. date .. ' ' }, 
 })) 
end) 

-------------------------------------------------------------------------- 
-- Maximize window on startup (mirrors events/gui-startup.lua) 
-------------------------------------------------------------------------- 
wezterm.on('gui-startup', function(cmd) 
 local tab, pane, window = mux.spawn_window(cmd or {}) 
 window:gui_window():maximize() 
end) 

-------------------------------------------------------------------------- 
-- Key tables (resize_font / resize_pane, entered via LEADER) 
-------------------------------------------------------------------------- 
config.key_tables = { 
 resize_font = { 
 { key = 'k', action = act.IncreaseFontSize }, 
 { key = 'j', action = act.DecreaseFontSize }, 
 { key = 'r', action = act.ResetFontSize }, 
 { key = 'q', action = act.PopKeyTable }, 
 { key = 'Escape', action = act.PopKeyTable }, 
 }, 
 resize_pane = { 
 { key = 'k', action = act.AdjustPaneSize({ 'Up', 1 }) }, 
 { key = 'j', action = act.AdjustPaneSize({ 'Down', 1 }) }, 
 { key = 'h', action = act.AdjustPaneSize({ 'Left', 1 }) }, 
 { key = 'l', action = act.AdjustPaneSize({ 'Right', 1 }) }, 
 { key = 'q', action = act.PopKeyTable }, 
 { key = 'Escape', action = act.PopKeyTable }, 
 }, 
} 

-------------------------------------------------------------------------- 
-- Key bindings (table mirrors the README's "All Key Bindings" section) 
-------------------------------------------------------------------------- 
config.disable_default_key_bindings = false 
config.keys = { 
 -- Misc / useful 
 { key = 'F1', mods = 'NONE', action = act.ActivateCopyMode }, 
 { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette }, 
 { key = 'F3', mods = 'NONE', action = act.ShowLauncher }, 
 { key = 'F4', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) }, 
 { key = 'F5', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) }, 
 { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen }, 
 { key = 'F12', mods = 'NONE', action = act.ShowDebugOverlay }, 
 { key = 'f', mods = SUPER, action = act.Search({ CaseSensitiveString = '' }) }, 
 { key = 'u', mods = SUPER_REV, action = act.OpenLinkAtMouseCursor }, 

 -- Copy+paste 
 { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') }, 
 { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') }, 

 -- Cursor movement 
 { key = 'LeftArrow', mods = SUPER, action = act.SendString('\x1bOH') }, 
 { key = 'RightArrow', mods = SUPER, action = act.SendString('\x1bOF') }, 

 -- Tabs: spawn / close 
 { key = 't', mods = SUPER, action = act.SpawnTab('DefaultDomain') }, 
 { key = 't', mods = SUPER_REV, action = act.SpawnTab({ DomainName = 'WSL:Ubuntu' }) }, 
 { key = 'w', mods = SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) }, 

 -- Tabs: navigation 
 { key = '[', mods = SUPER, action = act.ActivateTabRelative(1) }, 
 { key = ']', mods = SUPER, action = act.ActivateTabRelative(-1) }, 
 { key = '[', mods = SUPER_REV, action = act.MoveTabRelative(-1) }, 
 { key = ']', mods = SUPER_REV, action = act.MoveTabRelative(1) }, 

 -- Tabs: toggle tab bar 
 { key = '9', mods = SUPER, action = act.EmitEvent('toggle-tab-bar') }, 

 -- Tabs: title 
 { key = '0', mods = SUPER, action = act.PromptInputLine({ 
 description = 'Enter new name for tab', 
 action = wezterm.action_callback(function(window, pane, line) 
 if line then 
 window:active_tab():set_title(line) 
 end 
 end), 
 }) }, 
 { key = '0', mods = SUPER_REV, action = act.EmitEvent('undo-rename-tab') }, 

 -- Windows 
 { key = 'n', mods = SUPER, action = act.SpawnWindow }, 

 -- Panes: split 
 { key = '\\', mods = SUPER, action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) }, 
 { key = '\\', mods = SUPER_REV, action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) }, 

 -- Panes: zoom / close 
 { key = 'Enter', mods = SUPER, action = act.TogglePaneZoomState }, 
 { key = 'w', mods = SUPER, action = act.CloseCurrentPane({ confirm = false }) }, 

 -- Panes: navigation 
 { key = 'k', mods = SUPER_REV, action = act.ActivatePaneDirection('Up') }, 
 { key = 'j', mods = SUPER_REV, action = act.ActivatePaneDirection('Down') }, 
 { key = 'h', mods = SUPER_REV, action = act.ActivatePaneDirection('Left') }, 
 { key = 'l', mods = SUPER_REV, action = act.ActivatePaneDirection('Right') }, 
 { key = 'p', mods = SUPER_REV, action = act.PaneSelect({ mode = 'SwapWithActive' }) }, 

 -- Panes: scroll 
 { key = 'u', mods = SUPER, action = act.ScrollByLine(-5) }, 
 { key = 'd', mods = SUPER, action = act.ScrollByLine(5) }, 
 { key = 'PageUp', mods = 'NONE', action = act.ScrollByPage(-1) }, 
 { key = 'PageDown', mods = 'NONE', action = act.ScrollByPage(1) }, 

 -- Key tables (LEADER-prefixed) 
 { key = 'f', mods = 'LEADER', action = act.ActivateKeyTable({ name = 'resize_font', one_shot = false }) }, 
 { key = 'p', mods = 'LEADER', action = act.ActivateKeyTable({ name = 'resize_pane', one_shot = false }) }, 
} 

return config

