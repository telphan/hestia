local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

local volume_icon = sbar.add("item", "widgets.volume2", {
    position = "right",
    icon = {
        string = icons.volume._100,
	width = 5,
        align = "right",
        color = colors.transparent,
	padding_right = 10
    },
    label = {
    	width = 30,
    	align = "left",
	padding_right = 10,
    },
    popup = {
        align = "center"
    }
})



local volume_slider = sbar.add("slider", popup_width, {
    position = "popup." .. volume_icon.name,
    slider = {
        highlight_color = colors.blue,
        background = {
            height = 6,
            corner_radius = 3,
            color = colors.transparent
        },
        knob = {
            string = "􀀁",
            drawing = true
        }
    },
    background = {
        color = colors.transparent,
        height = 2,
        y_offset = -20
    },
    click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})

volume_icon:subscribe("volume_change", function(env)
    local volume = tonumber(env.INFO)
    local icon = icons.volume._0
    if volume > 60 then
        icon = icons.volume._100
    elseif volume > 30 then
        icon = icons.volume._66
    elseif volume > 10 then
        icon = icons.volume._33
    elseif volume > 0 then
        icon = icons.volume._10
    end

    local lead = ""
    if volume < 10 then
        lead = "0"
    end

    volume_icon:set({
        label = icon
    })

    volume_slider:set({
        slider = {
            percentage = volume
        }
    })
end)

local function volume_collapse_details()
    local drawing = volume_icon:query().popup.drawing == "on"
    if not drawing then
        return
    end
    volume_icon:set({
        popup = {
            drawing = false
        }
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
                drawing = true
            }
        })
        sbar.exec("SwitchAudioSource -t output -c", function(result)
            current_audio_device = result:sub(1, -2)
            sbar.exec("SwitchAudioSource -a -t output", function(available)
                current = current_audio_device
                local color = colors.grey
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
                            color = color
                        },
                        click_script = 'SwitchAudioSource -s "' .. device ..
                            '" && sketchybar --set /volume.device\\.*/ label.color=' .. colors.grey ..
                            ' --set $NAME label.color=' .. colors.white

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
volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.exited.global", volume_collapse_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
