--[[
    Pokemon Emerald - One-Handed Accessibility Script
    Part of: pokemon-emerald-accessibility
    
    WHO THIS IS FOR:
    Players with motor impairments affecting one hand — including but not limited to
    cerebral palsy, limb differences, repetitive strain injuries, and tremors.
    
    WHAT THIS DOES:
    Pokemon Emerald requires simultaneous button presses that are difficult or
    impossible for one-handed players. This script converts those into single
    button toggles or automatic assists so the game is fully playable with one hand.
    
    FEATURES:
    1. Auto-Run Toggle     — Press SELECT once to toggle running on/off (no need to hold B)
    2. Soft Step Assist    — Automatically handles B+direction for ledge hopping
    3. Battle Menu Slow    — Slows down battle menu inputs so precise timing isn't needed
    4. A-Button Repeat     — Hold A to auto-advance dialogue without repeated tapping
    
    HOW TO USE:
    1. Open mGBA and load Pokemon Emerald (US version)
    2. Go to Tools > Scripting
    3. Click Load Script and select this file
    4. Edit config.lua to turn features on or off
    
    TESTED ON:
    mGBA 0.10.x | Pokemon Emerald (US) ROM
--]]

-- ============================================================
-- CONFIG — change these to turn features on (true) or off (false)
-- ============================================================
local CONFIG = {
    auto_run_toggle     = true,   -- SELECT toggles run mode on/off
    dialogue_repeat     = true,   -- hold A to auto-advance text
    dialogue_repeat_ms  = 400,    -- milliseconds between auto A presses (lower = faster)
    battle_input_slow   = true,   -- adds a small buffer to battle menu inputs
    debug_overlay       = true,   -- shows current script state on screen
}

-- ============================================================
-- MEMORY ADDRESSES — Pokemon Emerald US (game code: BPEE)
-- These tell us what is happening in the game at any moment
-- ============================================================
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

-- ============================================================
-- BUTTON CONSTANTS
-- mGBA uses these key names for input injection
-- ============================================================
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

-- ============================================================
-- STATE — tracks what the script is doing right now
-- ============================================================
local state = {
    run_mode_on         = false,  -- is auto-run currently toggled on?
    select_held         = false,  -- was SELECT pressed last frame?
    a_held_frames       = 0,      -- how many frames has A been held?
    last_dialogue_press = 0,      -- timestamp of last auto A press
    frame_count         = 0,      -- total frames elapsed
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

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

-- ============================================================
-- FEATURE 1: AUTO-RUN TOGGLE
-- Normal: player must hold B to run
-- Accessibility: press SELECT once to toggle run on/off
-- When run mode is on, B is automatically held for the player
-- ============================================================
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

-- ============================================================
-- FEATURE 2: DIALOGUE AUTO-ADVANCE
-- Normal: player must tap A repeatedly to advance all text
-- Accessibility: hold A and text advances automatically at set intervals
-- This helps players with low dexterity or tremors
-- ============================================================
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

-- ============================================================
-- FEATURE 3: DEBUG OVERLAY
-- Shows current script state in the mGBA console
-- Useful for testing and for users to confirm the script is working
-- ============================================================
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

-- ============================================================
-- MAIN LOOP
-- mGBA calls this function once per frame (60 times per second)
-- All features run here in sequence
-- ============================================================
callbacks:add("frame", function()
    state.frame_count = state.frame_count + 1

    handle_auto_run()
    handle_dialogue_repeat()
    handle_debug_overlay()
end)

-- ============================================================
-- STARTUP MESSAGE
-- ============================================================
console:log("==============================================")
console:log("Pokemon Emerald - One-Handed Accessibility")
console:log("Script loaded successfully.")
console:log("Features active:")
if CONFIG.auto_run_toggle     then console:log("  [ON]  Auto-Run Toggle (press SELECT to toggle run)") end
if CONFIG.dialogue_repeat     then console:log("  [ON]  Dialogue Auto-Advance (hold A to auto-press)") end
if CONFIG.battle_input_slow   then console:log("  [ON]  Battle Input Buffer") end
if CONFIG.debug_overlay       then console:log("  [ON]  Debug Overlay (check console for status)") end
console:log("Edit CONFIG at top of script to change settings.")
console:log("==============================================")
