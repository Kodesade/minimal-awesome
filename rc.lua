local gears = require("gears")
local awful = require("awful")

require("awful.autofocus")
require("awful.mouse")

local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.hotkeys_popup.keys")

---------------------------------
------------ ERRORS -------------
---------------------------------
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup --
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

---------------------------------
------------ THEMES -------------
---------------------------------
beautiful.init(gears.filesystem.get_configuration_dir() .. "mytheme.lua")
beautiful.useless_gap = 5

---------------------------------
----------- VARIABLES -----------
---------------------------------
terminal = "kitty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

---------------------------------
------------ WIDGET -------------
---------------------------------
clock_widget = wibox.widget.textclock("%H:%M:%S",1)                                                 
clock_widget.align = 'center'

---------------------------------
------------ BUTTONS ------------
---------------------------------
local tasklist_buttons = gears.table.join(
        awful.button({ }, 1, function (c)
                if c == client.focus then
                        c.minimized = true
                else
                        c:emit_signal("request::activate", "tasklist", {raise = true})
                        
                end
        end)
)
client_buttons = gears.table.join(
        awful.button({},1,function(c)
                c:emit_signal("request::activate","mouse_click", {raise=true})
        end),
        awful.button({ modkey }, 1, function (c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
                awful.mouse.client.move(c)
        end),
        awful.button({ modkey }, 3, function (c)
                c:emit_signal("request::activate", "mouse_click", {raise = true})
                awful.mouse.client.resize(c)
        end)
)

---------------------------------
------------- SCREEN ------------
---------------------------------
awful.screen.connect_for_each_screen(function(s)

        awful.tag({"1"},s,awful.layout.layouts[1])
        s.prompt_widget = awful.widget.prompt()

        s.task_list_widget = awful.widget.tasklist {
                screen = s,
                filter = awful.widget.tasklist.filter.currenttags,
                buttons = tasklist_buttons,
                layout = {
                        spacing_widget = {
                                {
                                        forced_width = 5,
                                        forced_height = 24,
                                        thickness = 1,
                                        color = "white",
                                        widget = wibox.widget.separator
                                },
                                valign = "center",
                                halign = "center",
                                widget = wibox.container.place
                        },
                        spacing = 1,
                        layout = wibox.layout.fixed.horizontal
                },
                widget_template = {
                        nil,
                        {
                                wibox.widget.base.make_widget(),
                                forced_height = 24,
                                id = "background_role",
                                widget = wibox.container.background,
                        },
                        {
                                {
                                        id = "clienticon",
                                        widget = awful.widget.clienticon,
                                },
                                margins =5,
                                widget = wibox.container.margin
                        },
                        
                        create_callback = function(self,c,index,objects)
                                self:get_children_by_id('clienticon')[1].client = c
                        end,
                        layout = wibox.layout.align.vertical
                }
        }

        s.taskbar = awful.wibar({position = "bottom", screen = s})
        s.taskbar:setup {
                layout = wibox.layout.align.horizontal,
                s.prompt_widget,
                s.task_list_widget,
                clock_widget
        }

end)

---------------------------------
----------- BINDINGS ------------
---------------------------------

client_keys = gears.table.join(
        awful.key({modkey, "Shift"}, "c", function(c) c:kill() end,
                { description="Close", group="client" }
        ),
        awful.key({modkey}, "n", function(c)
                c.minimized = true
        end, {description = "Minimize", group="client"})
)
globalbinds = gears.table.join(
        awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
                { description="Show help", group="awesome" }
        ),
        awful.key({modkey}, "Return", function () awful.spawn(terminal) end,
                { description="Open a terminal", group="launcher" }
        ),
        awful.key({modkey, "Shift"}, "q", awesome.quit,
                { description="Quit awesome", group="awesome" }
        ),
        awful.key({modkey, "Control"}, "r", awesome.restart,
                { description="Reload awesome", group="awesome" }
        ),
        awful.key({modkey}, "r", function()
                awful.screen.focused().prompt_widget:run()
        end, {description="Run prompt",group="launcher"})
)

root.keys(globalbinds)

---------------------------------
------------- RULES -------------
---------------------------------
awful.rules.rules = {
        {
                rule = {},
                properties = {
                        border_width = beautiful.border_width,
                        border_color = beautiful.border_normal,
                        buttons = client_buttons,
                        keys = client_keys,
                        focus = awful.client.focus.filter,
                        raise = true,
                        screen = awful.screen.prefered,
                        placement = awful.placement.no_overlap+awful.placement.no_offscreen
                }
        }

}

---------------------------------
---------- SIGNALS --------------
---------------------------------
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)
