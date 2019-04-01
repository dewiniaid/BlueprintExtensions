-- Capabilities related to updating blueprints.
local Util = require("util")
local actions = require("actions")

local CLONED_BLUEPRINT = "BlueprintExtensions_cloned-blueprint"
local VERSION_PATTERN = "(v[.]?)(%d)$"  -- Matches version number at end of blueprints.
local DEFAULT_VERSION = " v.2"

local AWAITING_GUI = 1
local AWAITING_BP = 2

local Updater = {
    events = {}

}


function Updater.clone(player, event, action)
    --local player_index = event.player_index
    --local player = game.players[player_index]
    if not player.valid then
        return nil
    end
    local bp = Util.get_blueprint(player.cursor_stack)
    if not bp then
        return nil
    end
    local updater = {
        name = bp.name,
        label = bp.label,
        icons = bp.blueprint_icons,
        status = nil,
    }
    -- Create replacer tool
    if not player.clean_cursor() then
        return
    end
    Util.get_pdata(player.index).updater = updater
    player.cursor_stack.set_stack(CLONED_BLUEPRINT)
    if updater.label then
        player.cursor_stack.label = updater.label
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
    if not player.valid then
        return nil
    end
    local cursor = player.cursor_stack
    if not (cursor.valid and cursor.valid_for_read and cursor.name == CLONED_BLUEPRINT) then
        return nil
    end
    local pdata = Util.get_pdata(player_index)
    local updater = pdata.updater
    if not updater then
        return nil
    end
    cursor.set_stack(updater.name)
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
    cursor.blueprint_icons = updater.icons
    if updater.label then
        local label = updater.label
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

    -- Move this blueprint to a temporary item
    local stack = Util.store_item(player_index, 'updater-blueprint', player.cursor_stack)
    player.cursor_stack.clear()
    updater.status = AWAITING_GUI
    player.opened = stack
end


function Updater.on_gui_opened(event)
    -- If opening an item, this means our target blueprint was closed at some point and that any
    -- on_player_configured_blueprint events we see are nonsense.
    if event.gui_type ~= defines.gui_type.item then
        return
    end
    local pdata = Util.get_pdata(event.player_index)
    if not pdata.updater then
        return
    end

    if pdata.updater.status == AWAITING_GUI then
        pdata.updater.status = AWAITING_BP
    else
        pdata.updater = nil
    end
end


function Updater.on_player_configured_blueprint(event)
    local pdata = Util.get_pdata(event.player_index)
--    game.print(serpent.block(pdata.updater))
    if not pdata.updater or pdata.updater.status ~= AWAITING_BP then
        return
    end
    pdata.updater = nil  -- Nuke this.
    local player = game.players[event.player_index]
    if not player.clean_cursor() then
        player.print({"bpex.error_cannot_set_stack"})
    else
        player.cursor_stack.set_stack(Util.fetch_item(event.player_index, 'updater-blueprint'))
    end
end


actions['BlueprintExtensions_clone-blueprint'].handler = Updater.clone


Updater.events = {
    [defines.events.on_player_selected_area] = Updater.on_selected_area,
    [defines.events.on_player_alt_selected_area] = Updater.on_selected_area,
    [defines.events.on_player_configured_blueprint] = Updater.on_player_configured_blueprint,
    [defines.events.on_gui_opened] = Updater.on_gui_opened,
}


return Updater
