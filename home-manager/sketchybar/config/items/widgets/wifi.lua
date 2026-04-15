local colors = require("colors")
local settings = require("settings")

local SIZE = 26
local RADIUS = SIZE / 2
local BORDER = 8
local MIN_BORDER = 3
local popup_width = 260
local connected = false

sbar.exec("killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 0.5")

local WIFI_ICON = "󰺕"

local wifi = sbar.add("item", "widgets.wifi", {
    position = "right",
    icon = {
        drawing = true,
        string = WIFI_ICON,
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Regular"],
            size = 17,
        },
        color = colors.black,
        align = "center",
        padding_left = 1.5,
        padding_right = 0,
        width = SIZE,
        y_offset = 0.5,
    },
    label = {
        drawing = false,
    },
    background = {
        height = SIZE,
        corner_radius = RADIUS,
        color = colors.white,
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
        connected = result ~= ""
        if connected then
            wifi:set({
                icon = { color = colors.black },
                background = {
                    color = colors.white,
                    border_width = BORDER,
                    border_color = colors.black,
                },
            })
        else
            wifi:set({
                icon = { color = colors.red },
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
update_wifi()

local function parse_bps(s)
    if not s then return 0 end
    local n, unit = s:match("(%d+)%s*(%a+)")
    if not n then return 0 end
    n = tonumber(n)
    if unit == "KBps" then return n * 1000 end
    if unit == "MBps" then return n * 1000000 end
    return n
end

wifi:subscribe("network_update", function(env)
    if not connected then return end

    local up = parse_bps(env.upload)
    local down = parse_bps(env.download)
    local total = up + down

    if total < 1000 then return end

    -- traffic intensity buckets (more traffic = thinner border = bigger core pulse)
    local target = 3
    if total < 10000 then target = 6        -- 1-10 KB/s
    elseif total < 100000 then target = 5   -- 10-100 KB/s
    elseif total < 1000000 then target = 4  -- 100KB/s - 1MB/s
    end                                      -- >1MB/s: target = 3

    sbar.exec(string.format(
        "sketchybar --animate tanh 15 --set %s background.border_width=%d background.border_width=%d",
        wifi.name, target, BORDER
    ))
end)

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

