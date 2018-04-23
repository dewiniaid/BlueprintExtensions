-- Library functions and defines

CONST_EMPTY_TABLE = {}

-- Returns the item if it is a blueprint, the selected blueprint in the book if it is a blueprint book, or nil.
function get_blueprint(bp)
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

