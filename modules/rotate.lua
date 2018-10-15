local Util = require('Util')

local Rotate = {}

local function transform(ents)
    for _,ent in pairs(ents) do
        ent.direction = ((ent.direction or 0) + 2) % 8
	    ent.position.x, ent.position.y = ent.position.y * -1, ent.position.x * 1
    end
    return ents
end

local function pseudomatrixmultiply(position, mult)
	position.x, position.y = position.y * mult.x, position.x * mult.y
end

function Rotate.rotate(player_index)
    local player = game.players[player_index]
    local bp = Util.get_blueprint(player.cursor_stack)
    if not (bp and bp.is_blueprint_setup()) then
        return
    end
    local mult = { x = -1, y = 1 }

    local ents

    ents = bp.get_blueprint_entities()
    if ents then bp.set_blueprint_entities(transform(ents)) end

    ents = bp.get_blueprint_tiles()
    if ents then bp.set_blueprint_tiles(transform(ents)) end
end


script.on_event("BlueprintExtensions_rotate-clockwise", function(event) return Rotate.rotate(event.player_index) end)
return Rotate
