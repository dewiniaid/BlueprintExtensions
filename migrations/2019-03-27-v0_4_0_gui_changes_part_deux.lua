require('mod-gui')
local GUI = require('__BlueprintExtensions__/gui')
local mod_gui = require('mod-gui')

if not global.playerdata then
    global.playerdata = {}
end

for index, player in pairs(game.players) do
    local flow = mod_gui.get_button_flow(player)
    if flow then
        if flow.BPEX_Flip_H then flow.BPEX_Flip_H.destroy() end
        if flow.BPEX_Flip_V then flow.BPEX_Flip_V.destroy() end
    end
    GUI.setup(player)
end
