---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.font          = "Noto Sans 12"
theme.primary = "#232136"
theme.popup = "#2a273f"
theme.disabled = "#6e6a86"
theme.text = "#e0def4"
theme.border = "#908caa"

theme.border_width = dpi(1)
theme.border_focus = "#ffffff"
theme.border_normal = "#666666"

theme.fg_normal = theme.text
theme.bg_normal = theme.primary

theme.red = "#eb6f92"
theme.purple = "#c4a7e7"
theme.green = "#9ccfd8"
theme.blue = "#3e8fb0"
theme.orange = "#ea9a97"
theme.yellow = "#f6c177"

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
