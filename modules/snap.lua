local Util = require("util")
local min, max = math.min, math.max


local Snap = {
    EVENTS = {
        ["BlueprintExtensions_snap-n"] = {nil, 1},
        ["BlueprintExtensions_snap-s"] = {nil, 0},
        ["BlueprintExtensions_snap-w"] = {1, nil},
        ["BlueprintExtensions_snap-e"] = {0, nil},
        ["BlueprintExtensions_snap-center"] = {0.5, 0.5},
        ["BlueprintExtensions_snap-nw"] = {1, 1},
        ["BlueprintExtensions_snap-ne"] = {0, 1},
        ["BlueprintExtensions_snap-sw"] = {1, 0},
        ["BlueprintExtensions_snap-se"] = {0, 0},
    },
    NUDGE_EVENTS = {
        ["BlueprintExtensions_nudge-n"] = {0, -1},
        ["BlueprintExtensions_nudge-s"] = {0, 1},
        ["BlueprintExtensions_nudge-w"] = {-1, 0},
        ["BlueprintExtensions_nudge-e"] = {1, 0},
        ["BlueprintExtensions_nudge-nw"] = {-1, -1},
        ["BlueprintExtensions_nudge-ne"] = { 1, -1},
        ["BlueprintExtensions_nudge-sw"] = {-1, 1},
        ["BlueprintExtensions_nudge-se"] = { 1, 1},
    },
    ALIGNMENT_OVERRIDES = {
        ['straight-rail'] = 2,
        ['curved-rail'] = 2,
        ['train-stop'] = 2,
    },
    ROTATIONS = {
        [defines.direction.north]     = { 1,  2,  3,  4},
        [defines.direction.northeast] = { 3,  2,  1,  4},
        [defines.direction.east]      = { 4,  1,  2,  3},
        [defines.direction.southeast] = { 2,  1,  4,  3},
        [defines.direction.south]     = { 3,  4,  1,  2},
        [defines.direction.southwest] = { 1,  4,  3,  2},
        [defines.direction.west]      = { 2,  3,  4,  1},
        [defines.direction.northwest] = { 4,  3,  2,  1},
    }
}

function Snap.on_event(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then
        return nil
    end
    local bp = Util.get_blueprint(player.cursor_stack)
    if not bp then
        return nil
    end


    if not Snap.EVENTS[event.input_name] then
        if Snap.NUDGE_EVENTS[event.input_name] then
            local xdir, ydir = table.unpack(Snap.NUDGE_EVENTS[event.input_name])
            return Snap.nudge_blueprint(bp, xdir, ydir)
        end
        -- Should be unreachable
        return
    end

    local player_settings = player.mod_settings
    local center = (player_settings["BlueprintExtensions_cardinal-center"].value and 0.5) or nil
    local xdir, ydir = table.unpack(Snap.EVENTS[event.input_name])
    if xdir == nil then
        xdir = center
    elseif player_settings["BlueprintExtensions_horizontal-invert"].value then
        xdir = 1-xdir
    end
    if ydir == nil then
        ydir = center
    elseif player_settings["BlueprintExtensions_vertical-invert"].value then
        ydir = 1-ydir
    end
    return Snap.align_blueprint(bp, xdir, ydir)
end


local function update_bounds(bound, point, min_edge, max_edge)
    min_edge = point + min_edge
    max_edge = point + max_edge
    if bound.min == nil then
        bound.min = point
        bound.max = point
        bound.min_edge = min_edge
        bound.max_edge = max_edge
        return
    end
    bound.min = min(bound.min, point)
    bound.max = max(bound.max, point)
    bound.min_edge = min(bound.min_edge, min_edge)
    bound.max_edge = max(bound.max_edge, max_edge)
end


function Snap.blueprint_bounds(bp)
    local prototypes = game.entity_prototypes

    local bounds = {
        x = { min_edge = nil, min = nil, mid = nil, max_edge = nil, max = nil },
        y = { min_edge = nil, min = nil, mid = nil, max_edge = nil, max = nil },
    }
    local align = 1

    local rect = {}  -- Reduce GC churn by declaring this here and updating it in the loop rather than reinitializing
    -- every pass

    for _, entity in pairs(bp.get_blueprint_entities() or {}) do
        local rot = Snap.ROTATIONS[entity.direction or 0]
        local box = prototypes[entity.name].selection_box
        rect[1] = box.left_top.x
        rect[2] = box.left_top.y
        rect[3] = box.right_bottom.x
        rect[4] = box.right_bottom.y

        local x1 = rect[rot[1]]
        local y1 = rect[rot[2]]
        local x2 = rect[rot[3]]
        local y2 = rect[rot[4]]

        if x1 > x2 then
            x1, x2 = -x1, -x2
        end
        if y1 > y2 then
            y1, y2 = -y1, -y2
        end

        update_bounds(bounds.x, entity.position.x, x1, x2)
        update_bounds(bounds.y, entity.position.y, y1, y2)
        align = max(align, Snap.ALIGNMENT_OVERRIDES[entity.name] or align)
    end

    for _, tile in pairs(bp.get_blueprint_tiles() or {}) do
        update_bounds(bounds.x, tile.position.x, -0.5, 0.5)
        update_bounds(bounds.y, tile.position.y, -0.5, 0.5)
    end

    -- return math.floor(xmin), math.floor(ymin), math.ceil(xmax), math.ceil(ymax), align
    return bounds, align
end


local function offset(t, xoff, yoff)
    for _, v in pairs(t) do
        if not v.position then
            return nil
        end

        v.position.x = v.position.x + xoff
        v.position.y = v.position.y + yoff

    end
    return t
end


function Snap.offset_blueprint(bp, xoff, yoff)
    local entities = bp.get_blueprint_entities()
    local tiles = bp.get_blueprint_tiles()

    if entities then
        bp.set_blueprint_entities(offset(entities, xoff, yoff))
    end
    if tiles then
        bp.set_blueprint_tiles(offset(tiles, xoff, yoff))
    end
end


local function calculate_offset(dir, bound, align)
    local o = (dir ~= nil and math.floor(((-bound.min_edge - (dir * (bound.max_edge-bound.min_edge)))/ align)) * align) or 0
    if dir == 1 then
        -- The math works out to offset by the total width/height if we're aligning to max, but we want the max to
        -- end up under the cursor.
        return o+align
    end
    return o
end


function Snap.align_blueprint(bp, xdir, ydir)
    local bounds, align = Snap.blueprint_bounds(bp)
--    game.print("bounds.x=" .. serpent.line(bounds.x))
--    game.print("bounds.y=" .. serpent.line(bounds.y))
--    game.print("align=" .. align)


    local xoff = calculate_offset(xdir, bounds.x, align)
    local yoff = calculate_offset(ydir, bounds.y, align)

--    game.print("xoff=" .. xoff .. ", yoff=" .. yoff)

    return Snap.offset_blueprint(bp, xoff, yoff)
end


function Snap.nudge_blueprint(bp, xdir, ydir)
    local align = 1

    for _, entity in pairs(bp.get_blueprint_entities() or {}) do
        align = max(align, Snap.ALIGNMENT_OVERRIDES[entity.name] or align)
    end

    xdir = xdir * align
    ydir = ydir * align

    return Snap.offset_blueprint(bp, xdir, ydir)
end


for k,_ in pairs(Snap.EVENTS) do
    script.on_event(k, Snap.on_event)
end
for k,_ in pairs(Snap.NUDGE_EVENTS) do
    script.on_event(k, Snap.on_event)
end

return Snap
