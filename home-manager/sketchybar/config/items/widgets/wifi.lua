local colors = require("colors")
local settings = require("settings")

local SIZE = 26
local RADIUS = SIZE / 2
local BORDER = 8
local popup_width = 260

local wifi = sbar.add("item", "widgets.wifi", {
    position = "right",
    icon = {
        drawing = false,
    },
    label = {
        drawing = false,
    },
    background = {
        height = SIZE,
        corner_radius = RADIUS,
        color = colors.green,
        border_width = BORDER,
        border_color = colors.black,
        drawing = true,
    },
    width = SIZE,
    padding_left = 0,
    padding_right = 0,
    update_freq = 120,
    popup = {
        align = "right",
    },
})

local ssid = sbar.add("item", {
    position = "popup." .. wifi.name,
    width = popup_width,
    icon = {
        align = "left",
        string = "SSID:",
        width = 60,
    },
    label = {
        string = "...",
        width = popup_width - 60,
        align = "right",
    },
})

local ip = sbar.add("item", {
    position = "popup." .. wifi.name,
    width = popup_width,
    icon = {
        align = "left",
        string = "IP:",
        width = 60,
    },
    label = {
        string = "...",
        width = popup_width - 60,
        align = "right",
    },
})

local function update_wifi()
    sbar.exec("ipconfig getifaddr en0", function(result)
        local connected = result ~= ""
        if connected then
            wifi:set({
                background = {
                    color = colors.green,
                    border_width = BORDER,
                    border_color = colors.black,
                },
            })
        else
            wifi:set({
                background = {
                    color = colors.black,
                    border_width = BORDER,
                    border_color = colors.black,
                },
            })
        end
    end)
end

wifi:subscribe({"routine", "wifi_change", "system_woke"}, update_wifi)

wifi:subscribe("mouse.clicked", function()
    local should_draw = wifi:query().popup.drawing == "off"
    if should_draw then
        wifi:set({ popup = { drawing = true } })
        sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
            ssid:set({ label = result ~= "" and result or "Not connected" })
        end)
        sbar.exec("ipconfig getifaddr en0", function(result)
            ip:set({ label = result ~= "" and result or "N/A" })
        end)
    else
        wifi:set({ popup = { drawing = false } })
    end
end)

wifi:subscribe("mouse.exited.global", function()
    wifi:set({ popup = { drawing = false } })
end)

