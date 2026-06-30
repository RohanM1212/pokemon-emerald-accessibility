local last = -1
callbacks:add("frame", function()
    local v = emu:read8(0x02024064)
    if v ~= last then
        console:log("game_state = " .. v)
        last = v
    end
end)
console:log("gamestate debug loaded")