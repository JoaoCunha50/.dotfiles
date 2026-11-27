local vars = require("hypr-vars")

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "intl",
        accel_profile = "flat",
    },
    decoration = {
        screen_shader = "~/.config/caelestia/monitor.glsl",
    },
    general = {
        allow_tearing = true,
    }
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@240",
    position = "1920x0",
    scale    = 1,
})

hl.on("hyprland.start", function()
    hl.dispatch(hl.dsp.exec_cmd("[workspace 1 silent] kitty"))
    hl.dispatch(hl.dsp.exec_cmd("[workspace 2 silent] zen-browser"))
    hl.dispatch(hl.dsp.exec_cmd("[workspace 3 silent] zed"))
end)

hl.bind(vars.kbObsidian, hl.dsp.exec_cmd("caelestia toggle notes"))
hl.bind(vars.kbOsu, hl.dsp.exec_cmd(vars.app_osu))
hl.bind(vars.kbSteam, hl.dsp.exec_cmd("steam"))

hl.window_rule({
    match = { class = "^(steam)$" },
    workspace = "5"
})

hl.window_rule({ match = { class = "gamescope" }, fullscreen = true })

hl.window_rule({
    match = { class = "cs2" },
    immediate = true,
    idle_inhibit = "always",
})

hl.exec_cmd("systemctl --user start hyprland-session.target")
