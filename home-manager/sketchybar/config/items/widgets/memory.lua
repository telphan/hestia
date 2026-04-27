local colors = require("colors")

sbar.exec("killall memory_load >/dev/null; $CONFIG_DIR/helpers/event_providers/memory_load/bin/memory_load memory_update 2.0")

local memory = sbar.add("graph", "widgets.memory", 42, {
    position = "right",
    graph = {
        color = colors.white,
    },
    background = {
        height = 22,
        color = { alpha = 0 },
        border_color = { alpha = 0 },
        drawing = true,
    },
    icon = {
        drawing = false,
    },
    label = {
        drawing = false,
    },
    padding_right = 0,
    padding_left = 0,
})

memory:subscribe("memory_update", function(env)
    local load = tonumber((env.memory_load or ""):match("%d+"))
    if not load then return end
    memory:push({ load / 100. })

    local color = colors.white
    if load > 30 then
        if load < 60 then
            color = colors.yellow
        elseif load < 80 then
            color = colors.orange
        else
            color = colors.red
        end
    end

    memory:set({
        graph = {
            color = color,
        },
    })
end)

memory:subscribe("mouse.clicked", function(env)
    sbar.exec("open -a 'Activity Monitor'")
end)
