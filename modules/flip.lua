local Util = require('util')
require("mod-gui")


local Flip = {
    enabled = true,
    translations = {
        v = {
            axis = 'y',
            rail_offset = 13,
            default_offset = 12,
            signals = {
                [1] = 7,
                [2] = 6,
                [3] = 5,
                [5] = 3,
                [6] = 2,
                [7] = 1
            },
            train_stops = {
                [2] = 6,
                [6] = 2
            },
        },
        h = {
            axis = 'x',
            rail_offset = 9,
            default_offset = 16,
            signals = {
                [0] = 4,
                [1] = 3,
                [3] = 1,
                [4] = 0,
                [5] = 7,
                [7] = 5
            },
            train_stops = {
                [0] = 4,
                [4] = 1,
            },
        }
    },
    sides = {
        left = 'right',
        right = 'left'
    },
}

function Flip.setup_gui(player)
    local show = (Flip.enabled and player.mod_settings["BlueprintExtensions_show-buttons"].value)
    local flow = mod_gui.get_button_flow(player)

    if show and not flow.BPEX_Flip_H then
        local button
        button = flow.add {
            name = "BPEX_Flip_H",
            type = "sprite-button",
            style = mod_gui.button_style,
            sprite = "BPEX_Flip_H",
            tooltip = { "controls.BlueprintExtensions_flip-h" }
        }
        button.visible = true
        print(serpent.block(button))
        button = flow.add {
            name = "BPEX_Flip_V",
            type = "sprite-button",
            style = mod_gui.button_style,
            sprite = "BPEX_Flip_V",
            tooltip = { "controls.BlueprintExtensions_flip-v" }
        }
        button.visible = true
    elseif not show then
        if flow.BPEX_Flip_H then flow.BPEX_Flip_H.destroy() end
        if flow.BPEX_Flip_V then flow.BPEX_Flip_V.destroy() end
    end
    --
    --    local top = player.gui.top
    --
    --    if show and not top["BPEX_Flow"] then
    --        local flow = top.add{type = "flow", name = "BPEX_Flow", direction = 'horizontal'}
    --        flow.add{type = "button", name = "BPEX_Flip_H", style = "BPEX_Button_H"}
    --        flow.add{type = "button", name = "BPEX_Flip_V", style = "BPEX_Button_V"}
    --    elseif not show and top["BPEX_Flow"] then
    --        top["BPEX_Flow"].destroy()
    --    end
end


function Flip.check_for_other_mods()
--    if game.active_mods["PickerExtended"] then
--        game.print("[Blueprint Extensions] Picker Extended is installed.  Disabling our version of blueprint flipping.")
--        Flip.enabled = false
    if game.active_mods["Blueprint_Flip_Turn"] then
        game.print("[Blueprint Extensions] Blueprint Flipper and Turner is installed.  Disabling our version of blueprint flipping.")
        if game.active_mods["GDIW"] then
            game.print("Blueprint Extensions includes some improved functionality when flipping blueprints, such as correctly flipping splitter priorities and taking advantage of GDIW recipes.  To enable this functionality, disable Blueprint Flipper and Turner.")
        else
            game.print("Blueprint Extensions includes some improved functionality when flipping blueprints, such as correctly flipping splitter priorities.  To enable this functionality, disable Blueprint Flipper and Turner.")
        end
        Flip.enabled = false
    else
        Flip.enabled = true
    end
end

--[[ GDIW reversals:
Unmodified: BR or IR or OR
IR: OR or none
OR: IR or none
BR: unmodified
 ]]

local function _gdiw_recipe(recipe)
    return (game.recipe_prototypes[recipe]) and recipe or nil
end


function Flip.flip(player_index, translate)
    if game.active_mods["Blueprint_Flip_Turn"] then return end

    local player = game.players[player_index]
    local bp = Util.get_blueprint(player.cursor_stack)
    if not (bp and bp.is_blueprint_setup()) then
        return
    end

    local proto, name, dir
    local axis = translate.axis
    local ents
    local support_gdiw = player.mod_settings["BlueprintExtensions_support-gdiw"].value

    ents = bp.get_blueprint_entities()
    if ents then
        for _,ent in pairs(ents) do
            proto = game.entity_prototypes[ent.name]
            name = (proto and proto.type) or ent.name
            dir = ent.direction or 0
            if name == "curved-rail" then
                ent.direction = (translate.rail_offset - dir)%8
            elseif name == "storage-tank" then
                if dir == 2 or dir == 6 then
                    ent.direction = 4
                else
                    ent.direction = 2
                end
            elseif name == "rail-signal" or name == "rail-chain-signal" then
                if translate.signals[dir] ~= nil then
                    ent.direction = translate.signals[dir]
                end
            elseif name == "train-stop" then
                if translate.train_stops[dir] ~= nil then
                    ent.direction = translate.train_stops[dir]
                end
            else
                ent.direction = (translate.default_offset - dir)%8
            end

            ent.position[axis] = -ent.position[axis]
            if ent.drop_position ~= nil then
                ent.drop_position[axis] = -ent.drop_position[axis]
            end
            if ent.pickup_position ~= nil then
                ent.pickup_position[axis] = -ent.pickup_position[axis]
            end

            if Flip.sides[ent.input_priority] then
                ent.input_priority = Flip.sides[ent.input_priority]
            end
            if Flip.sides[ent.output_priority] then
                ent.output_priority = Flip.sides[ent.output_priority]
            end

            -- Support GDIW
            if support_gdiw and ent.recipe then
                local t
                local _, _, recipe, mod = string.find(ent.recipe, "^(.*)%-GDIW%-([BIO])R$")
                if mod == 'B' then      -- Both mirrored
                    ent.recipe = recipe
                elseif mod == 'I' then  -- Input mirrored
                    ent.recipe = _gdiw_recipe(recipe .. '-GDIW-OR') or recipe
                elseif mod == 'O' then  -- Output mirrored
                    ent.recipe = _gdiw_recipe(recipe .. '-GDIW-IR') or recipe
                else  -- Neither mirrored
                    recipe = ent.recipe
                    ent.recipe = (
                           _gdiw_recipe(recipe .. '-GDIW-BR')
                        or _gdiw_recipe(recipe .. '-GDIW-IR')
                        or _gdiw_recipe(recipe .. '-GDIW-OR')
                        or recipe
                    )
                end
            end
        end
        bp.set_blueprint_entities(ents)
    end

    ents = bp.get_blueprint_tiles()
    if ents then
        for _,ent in pairs(ents) do
            ent.direction = (
                translate.default_offset
                - (ent.direction or 0)
            )%8
            ent.position[axis] = -ent.position[axis]
        end
        bp.set_blueprint_tiles(ents)
    end
end


script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    Flip.check_for_other_mods()

    if game.active_mods["Blueprint_Flip_Turn"] then return end

    if event.setting_type == "runtime-per-user" and event.setting == "BlueprintExtensions_show-buttons" then
        return Flip.setup_gui(game.players[event.player_index])
    end
end
)

script.on_event("BlueprintExtensions_flip-h", function(event) return Flip.flip(event.player_index, Flip.translations.h) end)
script.on_event("BlueprintExtensions_flip-v", function(event) return Flip.flip(event.player_index, Flip.translations.v) end)
script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "BPEX_Flip_H" then
        return Flip.flip(event.player_index, Flip.translations.h)
    elseif event.element.name == "BPEX_Flip_V" then
        return Flip.flip(event.player_index, Flip.translations.v)
    end
end)


return Flip
