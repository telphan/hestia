local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local arrays = require("helpers.arrays")

local spaces = {}

local workspaces = get_workspaces()
local current_workspace = get_current_workspace()
local function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

local function compute_icons_for_space(env)
    for i, workspace in ipairs(workspaces) do
        sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}' --json ", function(apps)
	    local icon_line = {}
	    local label = ""
            local no_app = true

            for i, app in ipairs(apps) do
                no_app = false
                local app_name = app["app-name"]
                local lookup = app_icons[app_name]
                local icon = ((lookup == nil) and app_icons["default"] or lookup)
                table.insert(icon_line, icon)
            end

	    icon_line = arrays.dedup(icon_line)

            if no_app then
                label = ""
	    else
		label = table.concat(icon_line, " ")
            end

            sbar.animate("tanh", 10, function()
                spaces[i]:set({
                    label = label
                })
            end)
        end)
    end
end

for i, workspace in ipairs(workspaces) do
    local selected = workspace == current_workspace
    local space = sbar.add("item", "item." .. i, {
        icon = {
            font = {
                family = settings.font.numbers
            },
            string = i,
            padding_left = 8,
            padding_right = 4,
            color = settings.items.default_color(i),
            highlight_color = settings.items.highlight_color(i),
            highlight = selected,
            align = "center",
        },
        label = {
            padding_left = 4,
            padding_right = 8,
            color = settings.items.default_color(i),
            highlight_color = settings.items.highlight_color(i),
            font = "sketchybar-app-font:Regular:12.0",
            y_offset = 0,
            highlight = selected,
            align = "center",
        },
        padding_right = 1,
        padding_left = 1,
        background = {
            color = settings.items.colors.background,
            border_width = 1,
            height = settings.items.height,
            border_color = selected and settings.items.highlight_color(i) or settings.items.default_color(i)
        },
        popup = {
            background = {
                border_width = 5,
                border_color = colors.black
            }
        }
    })

    spaces[i] = space

    -- Define the icons for open apps on each space initially
    sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}' --json ", compute_icons_for_space)

    -- Padding space between each item
    sbar.add("item", "item." .. i .. "padding", {
        script = "",
        width = settings.items.gap
    })

    -- Item popup
    local space_popup = sbar.add("item", {
        position = "popup." .. space.name,
        padding_left = 5,
        padding_right = 0,
        background = {
            drawing = true,
            image = {
                corner_radius = 9,
                scale = 0.2
            }
        }
    })

    space:subscribe("aerospace_workspace_changed", function(env)
        local selected = env.FOCUSED_WORKSPACE == workspace

        space:set({
            icon = {
                highlight = selected
            },
            label = {
                highlight = selected
            },
            background = {
                border_color = selected and settings.items.highlight_color(i) or settings.items.default_color(i)
            }
        })

    end)

    space:subscribe("mouse.clicked", function(env)
        local SID = split(env.NAME, ".")[2]
        if env.BUTTON == "other" then
            space_popup:set({
                background = {
                    image = "item." .. SID
                }
            })
            space:set({
                popup = {
                    drawing = "toggle"
                }
            })
        else
            sbar.exec("aerospace workspace " .. SID)
        end
    end)

    space:subscribe("mouse.exited", function(_)
        space:set({
            popup = {
                drawing = false
            }
        })
    end)
end

local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true
})

space_window_observer:subscribe("aerospace_focus_change", compute_icons_for_space)
