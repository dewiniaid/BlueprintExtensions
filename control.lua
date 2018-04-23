require('util')
require('modules/snap')
require('modules/updater')
require('modules/flip')

-- local CONST_EMPTY_TABLE = {}  -- No GC churn

playerdata = {}


local function init_globals()
    global.playerdata = global.playerdata or {}
    playerdata = global.playerdata

    Flip.check_for_other_mods()

    for _, player in pairs(game.players) do
        Flip.setup_gui(player)
    end
end


script.on_init(init_globals)
script.on_configuration_changed(init_globals)
script.on_load(function() playerdata = global.playerdata end)
script.on_event(defines.events.on_player_removed, function(event)
    playerdata[event.player_index] = nil
end)
