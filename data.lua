--require 'prototypes/inputs'
require 'prototypes/items'
--require 'prototypes/style'
--require 'prototypes/shortcuts'

local actions = require('actions')

local function icon(s, x, y)
    return {
        filename = "__BlueprintExtensions__/graphics/shortcut-bar-buttons-" .. s .. ".png",
        priority = "extra-high-no-scale",
        flags = { "icon" },
        size = s,
        x = s*(x or 0),
        y = s*(y or 0),
        scale = 1
    }
end

for name, action in pairs(actions) do
    if action.key_sequence then
        data:extend{ {
            type = "custom-input",
            name = name,
            key_sequence = action.key_sequence,
            order = action.order
        }}
    end

    if action.icon ~= nil then
        local sprite = icon(32, action.icon, 1)
        sprite.type = "sprite"
        sprite.name = name

        data:extend {
            sprite,
            {
                name = name,
                type = "shortcut",
                localised_name = { "controls." .. name },
                associated_control_input = (action.key_sequence and name or nil),
                action = "lua",
                toggleable = action.toggleable or false,
                icon = icon(32, action.icon, 1),
                disabled_icon = icon(32, action.icon, 0),
                small_icon = icon(24, action.icon, 1),
                disabled_small_icon = icon(24, action.icon, 0),
                style = action.shortcut_style,
                order = "b[blueprints]-x[bpex]-" .. action.order
            }
        }
    end
end

data:extend({
    {
        type = "custom-input",
        name = "BlueprintExtensions_cleared_cursor_proxy",
        key_sequence = "",
        linked_game_control = "clean-cursor"
    }
})
