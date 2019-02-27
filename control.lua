local Util = require('util')
require('modules/snap')
require('modules/updater')
Flip = require('modules/flip')
require('modules/wireswap')
require('modules/rotate')

-- local CONST_EMPTY_TABLE = {}  -- No GC churn

local function init_globals()
    global.playerdata = global.playerdata or {}
    Flip.check_for_other_mods()

    for _, player in pairs(game.players) do
        Flip.setup_gui(player)
    end
end


script.on_init(init_globals)
script.on_configuration_changed(init_globals)
script.on_event(defines.events.on_player_removed, function(event)
    Util.clear_all_items(event.player_index)
    global.playerdata[event.player_index] = nil
end)
