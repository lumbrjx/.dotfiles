-- Hyprland Configuration (Lua)
-- Migrated from hyprland.conf for Hyprland 0.55+ (hyprlang deprecated -> Lua)
-- Original hyprlang config kept as hyprland.conf.bak

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "HDMI-A-3", mode = "1920x1080@100", position = "0x0", scale = 1.0 })
hl.monitor({ output = "",         mode = "preferred",      position = "auto",  scale = 1.2 })

local mainMod = "SUPER"
-- alacritty is a cargo binary; ~/.cargo/bin is not on the compositor's PATH
local term = os.getenv("HOME") .. "/.cargo/bin/alacritty"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("brave-browser")
    hl.exec_cmd(term)
    hl.exec_cmd("flatpak run com.discordapp.Discord")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync")
    -- Clipboard history (browse with SUPER + C)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("GDK_SCALE", "1")
hl.env("GDK_DPI_SCALE", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("GDK_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("AO_DRIVER", "pulse")
-- Make cargo-installed binaries reachable from binds/launchers
hl.env("PATH", os.getenv("PATH") .. ":" .. os.getenv("HOME") .. "/.cargo/bin")

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,ara",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

----------------
---- CURSOR ----
----------------

hl.config({
    cursor = {
        -- NVIDIA: let Hyprland own the HW cursor plane (clears greeter leftovers),
        -- but feed it via a CPU buffer to avoid the NVIDIA cursor ghosting.
        no_hardware_cursors = false,
        use_cpu_buffer = true,
    },
})

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 4,
        border_size = 2,

        -- Tokyo Night colors
        col = {
            active_border   = { colors = { "rgba(bb9af7ff)", "rgba(7aa2f7ff)" }, angle = 45 },
            inactive_border = "rgba(16161daa)",
        },

        layout        = "dwindle",
        allow_tearing = false,
    },

    decoration = {
        rounding = 8,

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })

----------------------
---- WINDOW RULES ----
----------------------

-- Assign apps to workspaces
hl.window_rule({ match = { class = "Alacritty" },     workspace = "2" })
hl.window_rule({ match = { class = "brave-browser" }, workspace = "3" })
hl.window_rule({ match = { class = "firefox" },       workspace = "4" })
hl.window_rule({ match = { class = "discord" },       workspace = "1" })
hl.window_rule({ match = { class = "Postman" },       workspace = "5" })

-- Floating + centered utility windows
hl.window_rule({ match = { class = "^(pavucontrol)$" },          float = true, center = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" },      float = true, center = true })
hl.window_rule({ match = { class = "^(nm-applet)$" },            float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(gnome-control-center)$" }, float = true, center = true })

---------------------
---- KEYBINDINGS ----
---------------------

-- Kill focused window
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.close())

-- Program launchers
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd("gnome-control-center"))
hl.bind(mainMod .. " + U",      hl.dsp.exec_cmd("obsidian"))
-- Clipboard history picker
hl.bind(mainMod .. " + C",      hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

-- Focus movement (vim-like)
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + M", hl.dsp.focus({ direction = "l" }))

-- Toggle waybar
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("~/.config/waybar/toggle-waybar.sh"))

-- Focus movement (arrows)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move windows (vim-like)
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ direction = "l" }))

-- Move windows (arrows)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Layout
hl.bind(mainMod .. " + H", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + V", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + S", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + Z", hl.dsp.group.toggle())
hl.bind(mainMod .. " + E", hl.dsp.group.next())

-- Toggle floating
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))

-- Focus urgent or last
hl.bind(mainMod .. " + Q", hl.dsp.focus({ urgent_or_last = true }))

-- Workspaces + move-to-workspace (1-9 -> 1-9, 0 -> 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Special bindings
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("hyprctl switchxkblayout current next"))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("rofi-bluetooth"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("~/rofi-wifi-menu/rofi-wifi-menu.sh"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + I",         hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("Print",                   hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))

-- Resize submap
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("J", hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("M", hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })

    hl.bind("left",  hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- Media keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),   { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                        { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                        { locked = true, repeating = true })

-- Mouse binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
