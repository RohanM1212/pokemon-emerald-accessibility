--[[
    cognitive_assist.lua
    This is for players who get overwhelmed by too much text or fast menus.
    Like when the screen flashes ten things at once and you miss what happened.
    It writes short summaries to a file and pauses if you need time to think.

    Addresses are for the USA Pokemon Emerald ROM, game code BPEE.
    If you are playing a European or Japanese version, these won't work.
    You will have to look at the memory values yourself to match them up.
--]]

local CONFIG = {
    summary_overlay      = true,   -- Saves what happened last turn to a text file
    decision_timer       = true,   -- Pauses the game if you stare at the menu too long
    timer_seconds        = 5,      -- How long to wait before it hits pause
    move_reminder        = true,   -- Tells you your move and PP when you look at it
    reduced_distraction  = true,   -- Stops the regular reader so you only hear the summary
    output_file = "C:/Users/rmukh/Desktop/pokemon-accessibility-dev/cognitive_queue.txt",
}

local ADDR = {
    game_state        = 0x02024064,  -- 8-bit, 2 means you are in a fight
    player_hp_current = 0x020240AC,  -- 16-bit
    enemy_hp_current  = 0x0202479A,  -- 16-bit
    menu_selection    = 0x02024044,  -- 8-bit, what option you are hovering over
    move_slot_hover   = 0x02024048,  -- 8-bit, tracks which move you are looking at
    -- The PP addresses below start near the main battle struct in EWRAM.
    -- I found these by tracking how values drop after a move is used.
    -- These need to be verified with live memory scanning before using in production.
    move_1_pp         = 0x020240C4,  -- 8-bit
    move_2_pp         = 0x020240C6,  -- 8-bit
    move_3_pp         = 0x020240C8,  -- 8-bit
    move_4_pp         = 0x020240CA,  -- 8-bit
}

local STATE = {
    frame_count         = 0,
    in_battle           = false,
    last_game_state     = -1,
    last_player_hp      = -1,
    last_enemy_hp       = -1,
    last_menu_selection = -1,
    last_move_hover     = -1,
    menu_inactive_frames = 0,
    paused_by_script    = false,
}

-- I used standard table names so the game text translates properly to English.
local BATTLE_MENU = {
    [0] = "FIGHT",
    [1] = "BAG",
    [2] = "POKEMON",
    [3] = "RUN"
}

local MOVE_NAMES = {
    [0] = "Tackle",
    [1] = "Growl",
    [2] = "Pound",
    [3] = "Scratch"
}

local function write_to_queue(text)
    -- This handles the distraction setting.
    -- If the user wants quiet, we wipe out the visual assist file so it stops talking.
    if CONFIG.reduced_distraction then
        local visual_file = io.open("C:/Users/rmukh/Desktop/pokemon-accessibility-dev/speech_queue.txt", "w")
        if visual_file then
            visual_file:write("")
            visual_file:close()
        end
    end

    local file = io.open(CONFIG.output_file, "a")
    if file then
        file:write(text .. "\n")
        file:close()
    end
end

local function read8(addr)
    return emu:read8(addr)
end

local function read16(addr)
    return emu:read16(addr)
end

local function handle_battle_summary()
    if not CONFIG.summary_overlay then return end

    local p_hp = read16(ADDR.player_hp_current)
    local e_hp = read16(ADDR.enemy_hp_current)

    -- Now, we only check this if we were already in a battle and things changed.
    -- It is like taking a snapshot after the round finishes.
    if state.last_player_hp ~= -1 and state.last_enemy_hp ~= -1 then
        if p_hp < state.last_player_hp or e_hp < state.last_enemy_hp then
            local p_diff = state.last_player_hp - p_hp
            local e_diff = state.last_enemy_hp - e_hp
            
            local summary = ""
            if e_diff > 0 then
                summary = summary .. "Enemy lost " .. e_diff .. " HP. "
            end
            if p_diff > 0 then
                summary = summary .. "You lost " .. p_diff .. " HP."
            end
            
            if summary ~= "" then
                write_to_queue(summary)
            end
        end
    end

    state.last_player_hp = p_hp
    state.last_enemy_hp = e_hp
end

local function handle_decision_timer()
    if not CONFIG.decision_timer then return end

    local selection = read8(ADDR.menu_selection)
    
    -- The thing is, we only want the timer running if they are stuck on the main choices.
    if selection == state.last_menu_selection then
        state.menu_inactive_frames = state.menu_inactive_frames + 1
    else
        state.menu_inactive_frames = 0
        state.paused_by_script = false
    end

    state.last_menu_selection = selection

    -- Sixty frames is one second.
    local limit = CONFIG.timer_seconds * 60
    if state.menu_inactive_frames >= limit and not state.paused_by_script then
        -- This feels weird because you are forcing a button press from code.
        -- But it is the only way to make the emulator stop without freezing the script.
        local keys = { start = true }
        emu:setKeys(keys)
        state.paused_by_script = true
        write_to_queue("Game paused. Take your time.")
    end
end

local function handle_move_reminder()
    if not CONFIG.move_reminder then return end

    local current_selection = read8(ADDR.menu_selection)
    -- Zero means they clicked FIGHT.
    if current_selection ~= 0 then return end

    local move_hover = read8(ADDR.move_slot_hover)

    if move_hover ~= state.last_move_hover then
        local move_name = MOVE_NAMES[move_hover] or "Unknown Move"
        
        -- We figure out the address based on which slot they are looking at.
        local pp_addr = ADDR.move_1_pp + (move_hover * 2)
        local pp_val = read8(pp_addr)

        write_to_queue(move_name .. ". " .. pp_val .. " PP left.")
        state.last_move_hover = move_hover
    end
end

callbacks:add("frame", function()
    state.frame_count = state.frame_count + 1

    local current_game_state = read8(ADDR.game_state)

    if current_game_state == 2 then
        state.in_battle = true
        handle_decision_timer()
        handle_move_reminder()
    else
        if state.in_battle then
            -- We just left a fight, so reset everything back to normal.
            state.in_battle = false
            state.last_player_hp = -1
            state.last_enemy_hp = -1
            state.last_move_hover = -1
            state.menu_inactive_frames = 0
            state.paused_by_script = false
        end
    end

    -- We poll this every thirty frames so we don't spam the text file while the game animates.
    if current_game_state == 2 and state.frame_count % 30 == 0 then
        handle_battle_summary()
    end

    state.last_game_state = current_game_state
end)

console:log("==============================================")
console:log("Pokemon Emerald - Cognitive Accessibility")
console:log("Script loaded successfully.")
console:log("Features active:")
if CONFIG.summary_overlay     then console:log("  [ON]  Battle Summary Overlay") end
if CONFIG.decision_timer      then console:log("  [ON]  Decision Timer Pause") end
if CONFIG.move_reminder       then console:log("  [ON]  Move Reminder") end
if CONFIG.reduced_distraction then console:log("  [ON]  Reduced Distraction Mode") end
console:log("Output file: " .. CONFIG.output_file)
console:log("==============================================")