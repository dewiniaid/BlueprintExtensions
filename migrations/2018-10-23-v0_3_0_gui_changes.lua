for index, player in pairs(game.players) do
    if player.gui.top.BPEX_Flow then
        player.gui.top.BPEX_Flow.destroy()
    end
end
