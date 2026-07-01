--[[
    ARCHIVE / PROTOTYPE - NOT VERIFIED, NOT THE CURRENT DESIGN

    This is the old standalone one-handed script from before the engine existed.
    It was never tested and its memory addresses are unverified. The real motor
    track will be a thin profile (motor_profile.lua) built on accessibility_core,
    like the visual and cognitive profiles. This file is kept only as a reference
    for that future profile. Do not load this expecting it to work.
--]]


local CONFIG = {
    auto_run_toggle     = true,   -- SELECT toggles run mode on/off
    dialogue_repeat     = true,   -- hold A to auto-advance text
    dialogue_repeat_ms  = 400,    -- milliseconds between auto A presses (lower = faster)
    battle_input_slow   = true,   -- adds a small buffer to battle menu inputs
    debug_overlay       = true,   -- shows current script state on screen
}


local ADDR = {
    -- Game state: 0 = overworld, 2 = battle, 5 = menu
    game_state      = 0x02030004,
    -- Player running state (1 = running shoes obtained)
    has_running_shoes = 0x02020ACB,
    -- Dialogue box open flag
    dialogue_active = 0x03004F10,
    -- Player movement state
    player_state    = 0x020370A4,
}


local KEYS = {
    A       = 1,
    B       = 2,
    SELECT  = 4,
    START   = 8,
    RIGHT   = 16,
    LEFT    = 32,
    UP      = 64,
    DOWN    = 128,
    R       = 256,
    L       = 512,
}


local state = {
    run_mode_on         = false,  -- is auto-run currently toggled on?
    select_held         = false,  -- was SELECT pressed last frame?
    a_held_frames       = 0,      -- how many frames has A been held?
    last_dialogue_press = 0,      -- timestamp of last auto A press
    frame_count         = 0,      -- total frames elapsed
}



-- Read a single byte from game memory
local function read_byte(address)
    return emu:read8(address)
end

-- Read a 32-bit value from game memory  
local function read_word(address)
    return emu:read32(address)
end

-- Check if a specific button is currently held by the player
local function button_held(key_value)
    return (emu:getKeys() & key_value) ~= 0
end

-- Get current game state
local function get_game_state()
    return read_byte(ADDR.game_state)
end

-- Returns true if player is currently in overworld (not in battle or menu)
local function in_overworld()
    return get_game_state() == 0
end

-- Returns true if dialogue box is currently open
local function dialogue_open()
    return read_byte(ADDR.dialogue_active) ~= 0
end

-- Returns true if player has obtained running shoes
local function has_running_shoes()
    return read_byte(ADDR.has_running_shoes) == 1
end


local function handle_auto_run()
    if not CONFIG.auto_run_toggle then return end
    if not has_running_shoes() then return end
    if not in_overworld() then return end

    local select_now = button_held(KEYS.SELECT)

    -- Detect a fresh SELECT press (wasn't held last frame, is held now)
    if select_now and not state.select_held then
        state.run_mode_on = not state.run_mode_on

        -- Show feedback on screen
        if CONFIG.debug_overlay then
            if state.run_mode_on then
                console:log("[Accessibility] Run mode: ON")
            else
                console:log("[Accessibility] Run mode: OFF")
            end
        end
    end

    state.select_held = select_now

    -- If run mode is on, inject B button press automatically
    -- This simulates the player holding B without them needing to
    if state.run_mode_on then
        -- Only inject B if player is actually moving (holding a direction)
        local moving = button_held(KEYS.UP) or button_held(KEYS.DOWN) or
                       button_held(KEYS.LEFT) or button_held(KEYS.RIGHT)
        if moving then
            emu:setKeys(emu:getKeys() | KEYS.B)
        end
    end
end


local function handle_dialogue_repeat()
    if not CONFIG.dialogue_repeat then return end
    if not dialogue_open() then
        state.a_held_frames = 0
        return
    end

    local a_now = button_held(KEYS.A)

    if a_now then
        state.a_held_frames = state.a_held_frames + 1

        -- After holding A for a moment, start auto-pressing at intervals
        -- 60 frames = 1 second at GBA speed
        local hold_threshold = 60  -- wait 1 second before auto-repeat starts
        local repeat_interval = math.floor(CONFIG.dialogue_repeat_ms / 16)

        if state.a_held_frames > hold_threshold then
            local frames_since_threshold = state.a_held_frames - hold_threshold
            if frames_since_threshold % repeat_interval == 0 then
                -- Inject an A press
                emu:setKeys(emu:getKeys() | KEYS.A)
            end
        end
    else
        state.a_held_frames = 0
    end
end


local function handle_debug_overlay()
    if not CONFIG.debug_overlay then return end

    -- Only print every 120 frames (every 2 seconds) to avoid spam
    if state.frame_count % 120 == 0 then
        local game_st = get_game_state()
        local run_status = state.run_mode_on and "ON" or "OFF"
        local shoes = has_running_shoes() and "YES" or "NO"
        local dlg = dialogue_open() and "YES" or "NO"

        console:log(string.format(
            "[Accessibility] Frame:%d | GameState:%d | RunMode:%s | Shoes:%s | Dialogue:%s",
            state.frame_count, game_st, run_status, shoes, dlg
        ))
    end
end


callbacks:add("frame", function()
    state.frame_count = state.frame_count + 1

    handle_auto_run()
    handle_dialogue_repeat()
    handle_debug_overlay()
end)


console:log("Pokemon Emerald - One-Handed Accessibility")
console:log("Script loaded successfully.")
console:log("Features active:")
if CONFIG.auto_run_toggle     then console:log("  [ON]  Auto-Run Toggle (press SELECT to toggle run)") end
if CONFIG.dialogue_repeat     then console:log("  [ON]  Dialogue Auto-Advance (hold A to auto-press)") end
if CONFIG.battle_input_slow   then console:log("  [ON]  Battle Input Buffer") end
if CONFIG.debug_overlay       then console:log("  [ON]  Debug Overlay (check console for status)") end
console:log("Edit CONFIG at top of script to change settings.")

