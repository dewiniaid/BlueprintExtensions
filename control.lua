local Util = require('util')
local actions = require('actions')
local mod_gui = require('mod-gui')
local GUI = require('gui')


local modules = {
    Snap = require('modules/snap'),
    Updater = require('modules/updater'),
    Flip = require('modules/flip'),
    Wireswap = require('modules/wireswap'),
    Rotate = require('modules/rotate'),
    Tempprint = require('modules/tempprint'),
    Landfill = require('modules/landfill')
}


local event_handlers = {}
local function add_event_handler(event, fn)
    local t = defines.events[event]
    event = t or event

    t = event_handlers[event]
    if not t then
        t = {}
        event_handlers[event] = t
    end
    t[#t+1] = fn
end


local function setup_event_handlers(event, handlers)
    if not handlers or #handlers == 0 then
        return
    end
    if #handlers == 1 then
        script.on_event(event, handlers[1])
    else
        script.on_event(event, function(event)
            for i = 1, #handlers do
                handlers[i](event)
            end
        end)
    end
end


-- Build list of required event handlers.
for modname, module in pairs(modules) do
    if module.events then
        for event, fn in pairs(module.events) do
            add_event_handler(event, fn)
        end
    end
end


local function call_module_methods(method, ...)
    for _, module in pairs(modules) do
        if module[method] then module[method](...) end
    end
end


local function dispatch_action(event, action)
    if not action or not action.handler then return end
    local player = game.players[event.player_index]
    return action.handler(player, event, action)

end


local function on_input_event(event)
    return dispatch_action(event, actions[event.input_name])
end


local function init_globals()
    global.playerdata = global.playerdata or {}
end


script.on_init(function()
    -- FIXME: Update all gui and shortcut bars.
    init_globals()
    call_module_methods('on_init')
end)


script.on_load(function() call_module_methods('on_load') end)


script.on_configuration_changed(function()
    -- FIXME: Update all gui and shortcut bars.
    init_globals()
    call_module_methods('on_configuration_changed')
end)


add_event_handler(
        defines.events.on_gui_click,
        function(event)
            return dispatch_action(event, actions[event.element.name])
        end
)

add_event_handler(
        defines.events.on_lua_shortcut,
        function(event)
            return dispatch_action(event, actions[event.prototype_name])
        end
)

add_event_handler(defines.events.on_player_removed, function(event)
    --call_module_methods('on_player_removed', event)
    Util.clear_all_items(event.player_index)
    global.playerdata[event.player_index] = nil
end)


add_event_handler(
        defines.events.on_player_cursor_stack_changed,
    function(event) GUI.update_visibility(game.players[event.player_index]) end
)


add_event_handler(defines.events.on_runtime_mod_setting_changed, function(event)
    if not (
            event.setting_type == 'runtime-per-user'
            and string.find(event.setting, "BlueprintExtensions_show-", 1, true) == 1
    ) then
        return
    end

    GUI.setup(game.players[event.player_index])
    call_module_methods('on_runtime_mod_setting_changed', event)
end)


add_event_handler(defines.events.on_player_created, function(event)
    GUI.setup(game.players[event.player_index])
end)


for name, action in pairs(actions) do
    if action.handler then
        script.on_event(name, on_input_event)
    else
        log("Warning: No action handler defined for " .. name)
    end
end


for event, handlers in pairs(event_handlers) do
    setup_event_handlers(event, handlers)
end
