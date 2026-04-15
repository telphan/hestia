local colors = require("colors")
local settings = require("settings")

local popup_width = 250

local VOLUME_ICONS = {
    mute = "",
    [1] = "󰪟",
    [2] = "󰪠",
    [3] = "󰪡",
    [4] = "󰪢",
    [5] = "󰪣",
    [6] = "󰪤",
    [7] = "󰪥",
}

local volume_icon = sbar.add("item", "widgets.volume2", {
    position = "right",
    icon = {
        drawing = false,
    },
    label = {
        string = VOLUME_ICONS[7],
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Regular"],
            size = 22.0,
        },
        color = colors.green,
        align = "center",
        padding_left = 0,
        padding_right = 0,
    },
    background = {
        drawing = false,
    },
    padding_left = 0,
    padding_right = 0,
    popup = {
        align = "right",
    },
})

local volume_slider = sbar.add("slider", popup_width, {
    position = "popup." .. volume_icon.name,
    slider = {
        highlight_color = colors.green,
        background = {
            height = 6,
            corner_radius = 3,
            color = colors.transparent,
        },
        knob = {
            string = "􀀁",
            drawing = true,
        },
    },
    background = {
        color = colors.transparent,
        height = 2,
        y_offset = -20,
    },
    click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

volume_icon:subscribe("volume_change", function(env)
    local volume = tonumber(env.INFO)

    local icon
    local color = colors.green

    if volume == 0 then
        icon = VOLUME_ICONS.mute
        color = colors.white
    elseif volume <= 14 then
        icon = VOLUME_ICONS[1]
    elseif volume <= 28 then
        icon = VOLUME_ICONS[2]
    elseif volume <= 42 then
        icon = VOLUME_ICONS[3]
    elseif volume <= 56 then
        icon = VOLUME_ICONS[4]
    elseif volume <= 70 then
        icon = VOLUME_ICONS[5]
    elseif volume <= 85 then
        icon = VOLUME_ICONS[6]
    else
        icon = VOLUME_ICONS[7]
    end

    -- Set the icon instantly
    volume_icon:set({
        label = {
            string = icon,
        },
    })

    -- Animate the color transition smoothly
    sbar.animate("tanh", 15, function()
        volume_icon:set({
            label = {
                color = color,
            },
        })
    end)

    volume_slider:set({
        slider = {
            percentage = volume,
        },
    })
end)

local function volume_collapse_details()
    local drawing = volume_icon:query().popup.drawing == "on"
    if not drawing then
        return
    end
    volume_icon:set({
        popup = {
            drawing = false,
        },
    })
    sbar.remove('/volume.device\\.*/')
end

local current_audio_device = "None"
local function volume_toggle_details(env)
    if env.BUTTON == "right" then
        sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
        return
    end

    local should_draw = volume_icon:query().popup.drawing == "off"
    if should_draw then
        volume_icon:set({
            popup = {
                drawing = true,
            },
        })
        sbar.exec("SwitchAudioSource -t output -c", function(result)
            current_audio_device = result:sub(1, -2)
            sbar.exec("SwitchAudioSource -a -t output", function(available)
                local current = current_audio_device
                local counter = 0

                for device in string.gmatch(available, '[^\r\n]+') do
                    local color = colors.grey
                    if current == device then
                        color = colors.white
                    end
                    sbar.add("item", "volume.device." .. counter, {
                        position = "popup." .. volume_icon.name,
                        width = popup_width,
                        align = "center",
                        label = {
                            string = device,
                            color = color,
                        },
                        click_script = 'SwitchAudioSource -s "' .. device ..
                            '" && sketchybar --set /volume.device\\.*/ label.color=' .. colors.grey ..
                            ' --set $NAME label.color=' .. colors.white,
                    })
                    counter = counter + 1
                end
            end)
        end)
    else
        volume_collapse_details()
    end
end

local function volume_scroll(env)
    local delta = env.SCROLL_DELTA
    sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_icon:subscribe("mouse.exited.global", volume_collapse_details)
