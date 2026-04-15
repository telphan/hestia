local colors = require("colors")
local settings = require("settings")

local SIZE = 26
local RADIUS = SIZE / 2
local BORDER = 3

local battery = sbar.add("item", "widgets.battery", {
    position = "right",
    icon = {
        drawing = false,
    },
    label = {
        string = "??",
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 9.0,
        },
        color = colors.white,
        align = "center",
        padding_left = 1,
        padding_right = 0,
        width = SIZE,
        y_offset = 1,
    },
    background = {
        height = SIZE,
        corner_radius = RADIUS,
        color = colors.transparent,
        border_width = BORDER,
        border_color = colors.green,
        drawing = true,
    },
    width = SIZE,
    padding_left = 0,
    padding_right = 0,
    update_freq = 180,
    popup = {
        align = "right",
    },
})

local remaining_time = sbar.add("item", {
    position = "popup." .. battery.name,
    icon = {
        string = "Time remaining:",
        width = 120,
        align = "left",
    },
    label = {
        string = "??:??h",
        width = 100,
        align = "right",
    },
})

battery:subscribe({"routine", "power_source_change", "system_woke"}, function()
    sbar.exec("pmset -g batt", function(batt_info)
        local found, _, charge = batt_info:find("(%d+)%%")
        local label = "??"
        if found then
            charge = tonumber(charge)
            label = tostring(charge)
        end

        local border_color = colors.green
        local bg_color = colors.transparent
        local charging, _, _ = batt_info:find("AC Power")

        if charging then
            border_color = colors.green
            bg_color = colors.with_alpha(colors.green, 0.2)
        elseif found then
            if charge > 60 then
                border_color = colors.green
            elseif charge > 40 then
                border_color = colors.yellow
            elseif charge > 20 then
                border_color = colors.orange
            else
                border_color = colors.red
            end
        end

        battery:set({
            label = {
                string = label,
            },
            background = {
                border_color = border_color,
                color = bg_color,
            },
        })
    end)
end)

battery:subscribe("mouse.clicked", function(env)
    local drawing = battery:query().popup.drawing
    battery:set({
        popup = {
            drawing = "toggle",
        },
    })

    if drawing == "off" then
        sbar.exec("pmset -g batt", function(batt_info)
            local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
            local label = found and remaining .. "h" or "No estimate"
            remaining_time:set({
                label = label,
            })
        end)
    end
end)

