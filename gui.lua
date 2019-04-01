local actions = require('actions')
local Util = require('util')

local GUI = {}

-- Generate sorted action list.
local sorted_actions = {}
for _, action in pairs(actions) do
    sorted_actions[#sorted_actions + 1] = action
end
table.sort(sorted_actions, function(a, b) return a.order < b.order end)


GUI.sorted_actions = sorted_actions


function GUI.setup(player)
    local flow = mod_gui.get_frame_flow(player)
    if flow.BPEX_Button_Flow then
        flow.BPEX_Button_Flow.destroy()
    end
    local parent

    for _, action in ipairs(sorted_actions) do
        if action.icon and player.mod_settings[action.visibility_setting].value then
            if not parent then
                parent = flow.add {
                    type = "flow",
                    name = "BPEX_Button_Flow",
                    enabled = true,
                    style = "slot_table_spacing_vertical_flow",
                    direction = "vertical"
                }
            end
            button = parent.add{
                name = action.name,
                type = "sprite-button",
                style = (action.shortcut_style and "shortcut_bar_button_" .. action.shortcut_style) or "shortcut_bar_button",
                sprite = action.name,
                tooltip = { "controls." .. action.name },
                enabled = true,
            }
        end
    end
    GUI.update_visibility(player, true)

    return parent  -- Might be nil if never created.
end


function GUI.update_visibility(player, force)
    local pdata = global.playerdata[player.index]
    if not pdata then
        pdata = {}
        global.playerdata[player.index] = pdata
    end

    local bp = (Util.get_blueprint(player.cursor_stack))
    local enabled = (bp and bp.is_blueprint_setup()) and true or false
    local was_enabled = pdata.buttons_enabled

    if (not force and was_enabled ~= nil and enabled == was_enabled) then
        return  -- No update needed.
    end

    local flow = mod_gui.get_frame_flow(player).BPEX_Button_Flow
    if flow then
        flow.visible = enabled
    end

    for name, action in pairs(actions) do
        if action.icon then
            player.set_shortcut_available(name, enabled)
        end
    end

    pdata.buttons_enabled = enabled
end


return GUI