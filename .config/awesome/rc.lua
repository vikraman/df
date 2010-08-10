-- ~/.config/awesome/rc.lua
--
-- vh4x0r's awesome configuration
-- using awesome 3.4.5 on Gentoo GNU/Linux
--
-- }}

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Widgets library
require("vicious")
-- Dynamic tagging library
require("eminent")

-- {{{ Variable definitions

terminal = "urxvtc"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
browser = "firefox"
filemgr = "nautilus --no-desktop --browser"
home = os.getenv("HOME")

-- Theme defines colours, icons, and wallpaper
beautiful.init(home .. "/.config/awesome/zenburn.lua")

exec = awful.util.spawn
sexec = awful.util.spawn_with_shell

modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters
layouts =
{
    awful.layout.suit.floating,        -- 1
    awful.layout.suit.tile,            -- 2
    awful.layout.suit.tile.left,       -- 3
    awful.layout.suit.tile.bottom,     -- 4
    awful.layout.suit.tile.top,        -- 5
    awful.layout.suit.fair,            -- 6
    awful.layout.suit.fair.horizontal, -- 7
    awful.layout.suit.spiral,          -- 8
    awful.layout.suit.spiral.dwindle,  -- 9
    awful.layout.suit.max,             -- 10
    awful.layout.suit.max.fullscreen,  -- 11
    awful.layout.suit.magnifier        -- 12
}
-- }}}

-- {{{ Tags
-- Define a tag table which holds all screen tags
tags = {
  name   = { "main", "web", "code", "file", "irc", "stuff", "virt", "ssh", "float" },
  layout = { layouts[3], layouts[2], layouts[4], layouts[12], layouts[6], layouts[7], layouts[10], layouts[12], layouts[1] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table
    tags[s] = awful.tag(tags.name, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

-- mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
--                                      menu = mymainmenu })
-- }}}

-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)
-- }}}
--
-- {{{ MPD widget
mpdwidget = widget({ type = "textbox" })
vicious.register(mpdwidget, vicious.widgets.mpd,
function(widget, args)
  if args["{state}"] == "Stop" then return ""
  else return ' '..args["{Artist}"]..' - '..args["{Title}"]
  end
end)
mpdwidget:buttons(awful.util.table.join(
awful.button({ }, 1, function () exec("mpc stop", false) end)
))
-- }}}
--
-- {{{ CPU widget
cpuicon = widget({ type = "imagebox" })
cpufreq = widget({ type = "textbox" })
cpugraph = awful.widget.graph()
cpuicon.image = image(beautiful.widget_cpu)
cpugraph:set_width(40):set_height(20)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_gradient_angle(0):set_gradient_colors({
  beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
})
vicious.register(cpugraph, vicious.widgets.cpu, "$1")
vicious.register(cpufreq, vicious.widgets.cpufreq, "$5", 31, "cpu0")
cpugraph.widget:buttons(awful.util.table.join(
awful.button({ }, 1, function () exec("gnome-system-monitor", false) end)
))
-- }}}
--
-- {{{ RAM widget
memicon = widget({ type = "imagebox" })
memgraph = awful.widget.graph()
memicon.image = image(beautiful.widget_mem)
memgraph:set_width(40):set_height(20)
memgraph:set_background_color(beautiful.fg_off_widget)
memgraph:set_gradient_angle(0):set_gradient_colors({
  beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
})
vicious.register(memgraph, vicious.widgets.mem, "$1")
memgraph.widget:buttons(awful.util.table.join(
awful.button({ }, 1, function () exec("gnome-system-monitor", false) end)
))
-- }}}
--
-- {{{ Temperature widget
tempicon = widget({ type = "imagebox" })
tempwidget = widget({ type = "textbox" })
tempicon.image = image(beautiful.widget_temp)
vicious.register(tempwidget, vicious.widgets.thermal, "$1C", 61, "thermal_zone1")
-- }}}
--
-- {{{ Battery widget
baticon = widget({ type = "imagebox" })
batwidget = widget({ type = "textbox" })
baticon.image = image(beautiful.widget_bat)
vicious.register(batwidget, vicious.widgets.bat,
function(widget, args)
  if args[3] == "N/A" then return args[1]
  else return args[1]..args[3]
  end
end, 61, "BAT0")
batwidget:buttons(awful.util.table.join(
awful.button({ }, 1, function () exec("gnome-power-statistics", false) end)
))
-- }}}
--
-- {{{ Network widget
dnicon = widget({ type = "imagebox" })
upicon = widget({ type = "imagebox" })
netwidget = widget({ type = "textbox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)
vicious.register(netwidget, vicious.widgets.net, '<span color="'
.. beautiful.fg_netdn_widget ..'">${eth1 down_kb}</span> <span color="'
.. beautiful.fg_netup_widget ..'">${eth1 up_kb}</span>', 4)
netwidget:buttons(awful.util.table.join(
awful.button({ }, 1, function () exec("gnome-system-monitor", false) end)
))
-- }}}
--
-- {{{ Date widget
dateicon = widget({ type = "imagebox" })
datewidget = widget({ type = "textbox" })
dateicon.image = image(beautiful.widget_date)
datewidget.text = "hello"
vicious.register(datewidget, vicious.widgets.date, "%a %b %d %R", 61)
-- }}}
--
-- }}}
--
-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ },        1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ },        3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ },        4, awful.tag.viewnext),
                    awful.button({ },        5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contain an icon indicating which layout we're using
    -- We need one layoutbox per screen
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            -- mylauncher,
            mytaglist[s],
	    mylayoutbox[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
	s == 1 and mysystray or nil,
	separator, datewidget, dateicon,
	separator, upicon, netwidget, dnicon,
	separator, batwidget, baticon,
	separator, tempwidget, tempicon,
	separator, memgraph.widget, memicon,
	separator, cpugraph.widget, cpufreq, cpuicon,
	separator, mpdwidget,
       	mytasklist[s],
	layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard programs
    awful.key({ modkey,           }, "Return", function () exec(terminal, false) end),
    awful.key({ modkey,           }, "w",      function () exec(browser, false) end),
    awful.key({ modkey,           }, "q",      function () exec(filemgr, false) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Multimedia keys
    awful.key({ modkey,           }, "#121",  function () exec("amixer -q set Master toggle", false) end),
    awful.key({ modkey,           }, "#122",  function () exec("amixer -q set Master 2dB-",   false) end),
    awful.key({ modkey,           }, "#123",  function () exec("amixer -q set Master 2dB+",   false) end),
    awful.key({ modkey,           }, "#172",  function () exec("mpc toggle",                  false) end),
    awful.key({ modkey,           }, "#173",  function () exec("mpc prev",                    false) end),
    awful.key({ modkey,           }, "#171",  function () exec("mpc next",                    false) end),

    -- Touchpad key
    awful.key({                   }, "#200",  function () exec("touchpadToggle.sh",           false) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digits we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Firefox" },
       properties = { tag = tags[1][2] } },
    { rule = { class = "Pidgin" },
       properties = { tag = tags[1][6] } },
    { rule = { class = "Skype" },
      properties = { floating = true } },
    { rule = { class = "URxvt" },
      properties = { size_hints_honor = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they do not set an initial position
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart programs
-- Launch apps
sexec("runonce urxvtd",                  false)
sexec("runonce xcompmgr",                false)
sexec("runonce xscreensaver -no-splash", false)
sexec("runonce blueman-applet",          false)
sexec("runonce gnome-power-manager",     false)
sexec("runonce conky",                   false)
-- }}}
