local colors = require("colors")
local icons = require("icons")

return {
    paddings = 3,
    group_paddings = 5,
    modes = {
        main = {
            icon = icons.apple,
            color = colors.rainbow[1],
	    font = {
		size = 10
	    }
        },
        service = {
            icon = icons.nuke,
            color = 0xffff9e64
        }
    },
    bar = {
        height = 30,
        padding = {
            x = 10,
            y = 0
        },
        background = colors.transparent
    },
    items = {
        height = 26,
        gap = 5,
        padding = {
            right = 16,
            left = 12,
            top = 0,
            bottom = 0
        },
        default_color = function(workspace)
            return colors.white
        end,
        highlight_color = function(workspace)
            return colors.green
        end,
        colors = {
            background = colors.transparent
        },
        corner_radius = 16
    },

    icons = "sketchybar-app-font:Regular:16.0", -- alternatively available: NerdFont

    font = {
        text = "FiraCode Nerd Font Mono", -- Used for text
        numbers = "FiraCode Nerd Font Mono", -- Used for numbers
        style_map = {
            ["Regular"] = "Regular",
            ["Semibold"] = "Medium",
            ["Bold"] = "SemiBold",
            ["Heavy"] = "Bold",
            ["Black"] = "ExtraBold"
        }
    }
}
