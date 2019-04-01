local Util = require('util')
local actions = require('actions')

local Wireswap = {}

function Wireswap.swap(player, event, action)
    local bp = Util.get_blueprint(player.cursor_stack)
    if not (bp and bp.is_blueprint_setup()) then
        return
    end

    local ents = bp.get_blueprint_entities()

    -- Source: https://gist.github.com/justarandomgeek/19b7844831087df40890229e7e92768d#file-flip-blueprint-wire-colors-lua
    if ents then
        for i,ent in pairs(ents) do
            if ent.connections then
                for j,conn in pairs(ent.connections) do
                    local temp = conn.red
                    conn.red = conn.green
                    conn.green = temp
                end
            end
        end
        bp.set_blueprint_entities(ents)
    end
end

actions["BlueprintExtensions_wireswap"].handler = Wireswap.swap

--script.on_event("BlueprintExtensions_wireswap", function(event) return Wireswap.swap(game.players[event.player_index]) end)


return Wireswap
