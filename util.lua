-- Library functions and defines

local Util = {}

-- Returns the item if it is a blueprint, the selected blueprint in the book if it is a blueprint book, or nil.
function Util.get_blueprint(bp)
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

-- Create or return a dummy storage surface
function Util.get_dummy_surface()
    if game.surfaces.surface_of_holding then
        return game.surfaces.surface_of_holding
    end

    local none = { frequency = "none" }
    local autoplace_controls = {}
    for k,_ in pairs(game.autoplace_control_prototypes) do
        autoplace_controls[k] = none
    end
    return game.create_surface(
        'surface_of_holding',
        { width=1, height=1, autoplace_controls = autoplace_controls }
    )
end

-- Store an item stack in the Surface of Holding(tm)
function Util.store_item(player_index, key, item)
    local pdata = Util.get_pdata(player_index)
    if not pdata.stored_items then
        pdata.stored_items = {}
    end

    if not (pdata.stored_items[key] and pdata.stored_items[key].valid) then
        pdata.stored_items[key] = Util.get_dummy_surface().create_entity{name='item-on-ground', position={x=0,y=0}, stack={name='blueprint'}}
    end
    pdata.stored_items[key].stack.set_stack(item)
    return pdata.stored_items[key].stack
end

-- Clear an item stack in the Surface of Holding(tm)
function Util.clear_item(player_index, key)
    local pdata = global.playerdata[player_index]
    if not pdata or not pdata.stored_items or not pdata.stored_items[key] then
        return
    end
    if pdata.stored_items[key].valid then
        pdata.stored_items[key].destroy()
    end
    pdata.stored_items[key] = nil
end

-- Clear ALL item stacks in the Surface of Holding
function Util.clear_all_items(player_index)
    local pdata = global.playerdata[player_index]
    if not pdata or not pdata.stored_items then
        return
    end
    for _,ent in pairs(pdata.stored_items) do
        if ent and ent.valid then
            ent.destroy()
        end
    end
    pdata.stored_items = {}
end

-- Fetch an item stack in the Surface of Holding(tm)
function Util.fetch_item(player_index, key)
    local pdata = global.playerdata[player_index]
    if not pdata or not pdata.stored_items or not pdata.stored_items[key] then
        return nil
    end
    if pdata.stored_items[key].valid then
        return pdata.stored_items[key].stack
    end
    pdata.stored_items[key] = nil
    return
end

-- Get or initialize player data.
function Util.get_pdata(player_index)
    local pdata = global.playerdata[player_index]
    if not pdata then
        pdata = {}
        if global.playerdata[player_index] = pdata
    end
    return pdata
end


return Util
