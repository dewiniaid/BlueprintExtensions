-- Capabilities related to updating blueprints.
require("util")

local CLONED_BLUEPRINT = "BlueprintExtensions_cloned-blueprint"
local VERSION_PATTERN = "(v[.]?)(%d)$";  -- Matches version number at end of blueprints.
local DEFAULT_VERSION = " v.2"

Updater = {}


function Updater.clone(player_index)
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


function Updater.on_selected_area(event)
    if event.item ~= CLONED_BLUEPRINT then
        return
    end
    local alt = (event.name == defines.events.on_player_alt_selected_area)

    local player_index = event.player_index
    local area = event.area
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

    -- Remember the item number for this blueprint.
    pdata.item_number = cursor.item_number
    player.opened = cursor
    -- player.clean_cursor()
end


function Updater.on_gui_opened(event)
    -- If opening an item, this means our target blueprint was closed at some point and that any
    -- on_player_configured_blueprint events we see are nonsense.
    if event.gui_type ~= defines.gui_type.item then
        return
    end
    local pdata = playerdata[event.player_index]
    if event.item and event.item.item_number == pdata.item_number then
        return
    end

    if pdata and pdata.item_number then
        pdata.item_number = nil
    end
end


function Updater.on_player_configured_blueprint(event)
    local pdata = playerdata[event.player_index]
    local player = game.players[event.player_index]
    if not (pdata and pdata.item_number) then
        return
    end
    local num = pdata.item_number
    pdata.item_number = nil

    -- Try to find blueprint in the player's inventory so we can pick it up again, like normal BPs work.
    -- Quick cursor_stack check first since it's painless
    if player.cursor_stack.valid_for_read and player.cursor_stack.item_number == num then
        return  -- Already holding it.
    end

    local item
    for _,inv in pairs({player.get_inventory(defines.inventory.player_main), player.get_quickbar()}) do
        for i=1,#inv do
            item = inv[i]
            if item.valid_for_read and item.item_number == num and item.name == pdata.name then
                player.clean_cursor()
                player.cursor_stack.swap_stack(item)
                return
            end
        end
    end
end


script.on_event("BlueprintExtensions_clone-blueprint", function(event) return Updater.clone(event.player_index) end)
script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, Updater.on_selected_area)
--script.on_event(defines.events.on_gui_opened, Updater.on_gui_opened)
--script.on_event(defines.events.on_player_configured_blueprint, Updater.on_player_configured_blueprint)
