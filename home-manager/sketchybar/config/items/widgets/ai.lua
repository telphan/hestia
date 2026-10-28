local colors = require("colors")
local settings = require("settings")

-- The SketchyBar service's PATH holds a literal, unexpanded /etc/profiles/per-user/$USER/bin.
local ai_attention = "/etc/profiles/per-user/" .. os.getenv("USER") .. "/bin/ai-attention"

local size = 24
-- Plan usage at or above this counts as full.
local full_at = 95

-- Each tool is its brand icon on a circle that fills with its colour as plan usage
-- rises, so the icon disappears into it once usage is full.
-- The icon turns red while a session waits on you; clicking focuses that session.
local function ai_item(tool, glyph, color)
    local item = sbar.add("item", "widgets.ai." .. tool, {
        position = "right",
        icon = {
            string = glyph,
            color = color,
            font = {
                family = settings.font.text,
                style = settings.font.style_map["Regular"],
                size = 16.5,
            },
            width = size,
            align = "center",
            -- SketchyBar draws the glyph about 3/4pt left of the circle's centre.
            padding_left = 1,
            padding_right = -1,
        },
        label = { drawing = false },
        background = {
            drawing = true,
            height = size,
            corner_radius = size / 2,
            color = { alpha = 0 },
        },
        padding_left = settings.paddings,
        padding_right = settings.paddings,
    })

    item:subscribe("mouse.clicked", function(_)
        sbar.exec(ai_attention .. " focus " .. tool)
    end)

    return { item = item, color = color }
end

local codex = ai_item("codex", "\u{ec81}", 0xff76cce0)
local claude = ai_item("claude", "\u{ec82}", 0xffd97757)

local function show(widget, usage, waiting)
    local fill = usage and math.min(usage / full_at, 1) or 0
    local alpha = math.floor(fill * 255 + 0.5)
    local icon_color = widget.color
    if (waiting or 0) > 0 then
        icon_color = colors.red
    elseif not usage then
        icon_color = colors.grey
    end

    sbar.animate("tanh", 15, function()
        widget.item:set({
            icon = { color = icon_color },
            background = { color = (alpha << 24) | (widget.color & 0xffffff) },
        })
    end)
end

local function update()
    sbar.exec(ai_attention .. " status", function(status)
        if type(status) ~= "table" then
            return
        end
        local pending = status.pending or {}
        show(claude, status.claude, pending.claude)
        show(codex, status.codex, pending.codex)
    end)
end

claude.item:set({ update_freq = 60 })
claude.item:subscribe({ "routine", "forced", "ai_attention_change" }, update)

-- Looking at a waiting session's window counts as attending to it.
claude.item:subscribe("aerospace_focus_change", function(_)
    sbar.exec(ai_attention .. " clear-focused")
end)
