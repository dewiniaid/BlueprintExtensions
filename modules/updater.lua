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


function Updater.on_selected_area(event, alt)
    if event.item ~= CLONED_BLUEPRINT then
        return
    end

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

    player.opened = cursor
end

script.on_event("BlueprintExtensions_clone-blueprint", function(event) return Updater.clone(event.player_index) end)
script.on_event(defines.events.on_player_selected_area, function(event)
    return Updater.on_selected_area(event, false)
end)
script.on_event(defines.events.on_player_alt_selected_area, function(event)
    return Updater.on_selected_area(event, true)
end)