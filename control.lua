local min, max = math.min, math.max

local CLONED_BLUEPRINT = "BlueprintExtensions_cloned-blueprint"
local CONST_EMPTY_TABLE = {}  -- No GC churn
local SNAP_EVENTS = {
    ["BlueprintExtensions_snap-n"] = {nil, 1},
    ["BlueprintExtensions_snap-s"] = {nil, 0},
    ["BlueprintExtensions_snap-w"] = {1, nil},
    ["BlueprintExtensions_snap-e"] = {0, nil},
    ["BlueprintExtensions_snap-center"] = {0.5, 0.5},
    ["BlueprintExtensions_snap-nw"] = {1, 1},
    ["BlueprintExtensions_snap-ne"] = {0, 1},
    ["BlueprintExtensions_snap-sw"] = {1, 0},
    ["BlueprintExtensions_snap-se"] = {0, 0},
}

local VERSION_PATTERN = "(v[.]?)(%d)$";  -- Matches version number at end of blueprints.
local DEFAULT_VERSION = " v.2"


playerdata = {}


local function init_globals()
    global.playerdata = global.playerdata or {}
    playerdata = global.playerdata
end

script.on_init(init_globals)
script.on_configuration_changed(init_globals)
script.on_load(function() playerdata = global.playerdata end)
script.on_event(defines.events.on_player_removed, function(event)
    playerdata[event.player_index] = nil
end)


function get_blueprint(bp)
    -- Returns the item if it is a blueprint, the selected blueprint in the book if it is a blueprint book, or nil.
    if not (bp.valid and bp.valid_for_read) then
        return nil
    end
    if bp.is_blueprint_book and bp.active_index then
        return get_blueprint(bp.get_inventory(defines.inventory.item_main)[bp.active_index])
    end
    if bp.is_blueprint then
        return bp
    end
    return nil
end


function clone_blueprint(player_index)
    local player = game.players[player_index]
    if not player.valid then
        return nil
    end
    local bp = get_blueprint(player.cursor_stack)
    if not bp then
        return nil
    end
    local pdata = {
        name = bp.name,
        label = bp.label,
        icons = bp.blueprint_icons,
    }

    -- Create replacer tool
    if player.clean_cursor() then
        player.cursor_stack.set_stack(CLONED_BLUEPRINT)
        if pdata.label then
            player.cursor_stack.label = pdata.label
        end
        playerdata[player_index] = pdata
    end
end


function on_selected_area(player_index, area, alt)
    -- Handle blueprint replacer.
    local player = game.players[player_index]
    local surface = player.surface
    if not player.valid then
        return nil
    end
    local cursor = player.cursor_stack
    if not (cursor.valid and cursor.valid_for_read and cursor.name == CLONED_BLUEPRINT) then
        return nil
    end
    local pdata = playerdata[player_index]
    if not pdata then
        return nil
    end
    cursor.set_stack(pdata.name)
    cursor.create_blueprint{
        surface=player.surface,
        force=player.force,
        always_include_tiles=true,
        area=area
    }
    if not cursor.is_blueprint_setup() then  -- Empty blueprint area?
        cursor.set_stack(CLONED_BLUEPRINT)
        return
    end
    cursor.blueprint_icons = pdata.icons
    if pdata.label then
        local label = pdata.label
        local found
        local versioning = player.mod_settings[
            alt and "BlueprintExtensions_alt-version-increment" or "BlueprintExtensions_version-increment"
        ].value
        if versioning ~= 'off' then
            label, found = string.gsub(label, VERSION_PATTERN, function(v, n) return v .. (n+1) end)
            if found == 0 and versioning == 'on' then
                label = label .. DEFAULT_VERSION
            end
        end
        cursor.label = label
    end

    player.opened = cursor
end


script.on_event("BlueprintExtensions_clone-blueprint", function(event) return clone_blueprint(event.player_index) end)
script.on_event(defines.events.on_player_selected_area, function(event)
    if event.item ~= CLONED_BLUEPRINT then
        return
    end
    on_selected_area(event.player_index, event.area, false)
end)
script.on_event(defines.events.on_player_alt_selected_area, function(event)
    if event.item ~= CLONED_BLUEPRINT then
        return
    end
    on_selected_area(event.player_index, event.area, true)
end)


local ALIGNMENT_OVERRIDE = {
    ['straight-rail'] = 2,
    ['curved-rail'] = 2,
    ['train-stop'] = 2,
}

local function blueprint_bounds(bp)
    local prototypes = game.entity_prototypes

    local bounds = {
        x = { min_edge = nil, min = nil, mid = nil, max_edge = nil, max = nil },
        y = { min_edge = nil, min = nil, mid = nil, max_edge = nil, max = nil },
    }
    local align = 1

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

    local ROTATIONS = {
        [defines.direction.north]     = { 1,  2,  3,  4},
        [defines.direction.northeast] = { 3,  2,  1,  4},
        [defines.direction.east]      = { 4,  1,  2,  3},
        [defines.direction.southeast] = { 2,  1,  4,  3},
        [defines.direction.south]     = { 3,  4,  1,  2},
        [defines.direction.southwest] = { 1,  4,  3,  2},
        [defines.direction.west]      = { 2,  3,  4,  1},
        [defines.direction.northwest] = { 4,  3,  2,  1},
    }

    local rect = {}  -- Reduce GC churn by declaring this here and updating it in the loop rather than reinitializing
    -- every pass

    for ix, entity in pairs(bp.get_blueprint_entities() or CONST_EMPTY_TABLE) do
        local rot = ROTATIONS[entity.direction or 0]
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
        align = max(align, ALIGNMENT_OVERRIDE[entity.name] or align)
    end

    for _, tile in pairs(bp.get_blueprint_tiles() or CONST_EMPTY_TABLE) do
        update_bounds(bounds.x, tile.position.x, -0.5, 0.5)
        update_bounds(bounds.y, tile.position.y, -0.5, 0.5)
    end

    -- return math.floor(xmin), math.floor(ymin), math.ceil(xmax), math.ceil(ymax), align
    return bounds, align
end

local function offset_blueprint(bp, xoff, yoff)
    local function offset(t)
        for k, v in pairs(t) do
            if not v.position then
                return nil
            end

            v.position.x = v.position.x + xoff
            v.position.y = v.position.y + yoff

        end
        return t
    end

    local entities = bp.get_blueprint_entities()
    local tiles = bp.get_blueprint_tiles()

    if entities then
        bp.set_blueprint_entities(offset(entities))
    end
    if tiles then
        bp.set_blueprint_tiles(offset(tiles))
    end
end

local function align_blueprint(bp, xdir, ydir)
    local bounds, align = blueprint_bounds(bp)
--    game.print("bounds.x=" .. serpent.line(bounds.x))
--    game.print("bounds.y=" .. serpent.line(bounds.y))
--    game.print("align=" .. align)

    local function calculate_offset(dir, bound)
        local o = (dir ~= nil and math.floor(((-bound.min_edge - (dir * (bound.max_edge-bound.min_edge)))/ align)) * align) or 0
        if dir == 1 then
            -- The math works out to offset by the total width/height if we're aligning to max, but we want the max to
            -- end up under the cursor.
            return o+align
        end
        return o
    end

    local xoff = calculate_offset(xdir, bounds.x)
    local yoff = calculate_offset(ydir, bounds.y)

--    game.print("xoff=" .. xoff .. ", yoff=" .. yoff)

    return offset_blueprint(bp, xoff, yoff)
end


local function on_snap_event(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then
        return nil
    end
    local bp = get_blueprint(player.cursor_stack)
    if not bp then
        return nil
    end

    local player_settings = player.mod_settings

    local center = (player_settings["BlueprintExtensions_cardinal-center"].value and 0.5) or nil
    local xdir, ydir = table.unpack(SNAP_EVENTS[event.input_name])
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
    align_blueprint(bp, xdir, ydir)
end

for k,_ in pairs(SNAP_EVENTS) do
    script.on_event(k, on_snap_event)
end
