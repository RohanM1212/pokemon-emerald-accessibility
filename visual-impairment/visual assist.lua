--[[
    ARCHIVE / PROTOTYPE - NOT VERIFIED, NOT THE CURRENT DESIGN

    This is the old standalone visual script from before the engine existed.
    It uses the old battle-state address (0x02024064) which turned out to be
    wrong (it reads the same in and out of battle). The current visual track is
    visual_profile.lua, built on accessibility_core with the verified battle_flag
    address. This file is kept only as a reference. Do not load it expecting it
    to work correctly.
--]]

-- set output_file to wherever speech_queue.txt lives on your machine
local CONFIG = {
    hp_warning_threshold  = 0.25,
    announce_battle_start = true,
    announce_hp_changes   = true,
    announce_menu         = true,
    output_file = "C:/Users/rmukh/Desktop/pokemon-accessibility-dev/speech_queue.txt",
}

-- confirmed addresses for usa, europe rom
local ADDR = {
    game_state        = 0x02024064,  -- 8-bit, 2 = battle
    player_hp_current = 0x020240AC,  -- 16-bit
    player_hp_max     = 0x02024544,  -- 16-bit
    player_level      = 0x02024540,  -- 8-bit
    enemy_hp_current  = 0x0202479A,  -- 16-bit
    enemy_hp_max      = 0x0202479C,  -- 16-bit
    enemy_level       = 0x02024798,  -- 8-bit
    menu_selection    = 0x02023340,  -- 8-bit
}

local state = {
    last_game_state     = -1,
    last_player_hp      = -1,
    last_enemy_hp       = -1,
    last_menu_selection = -1,
    in_battle           = false,
    hp_warning_given    = false,
    frame_count         = 0,
}

-- only hoenn starters and early route pokemon for now
-- add more as needed
local POKEMON_NAMES = {
    [1]="Bulbasaur",[2]="Ivysaur",[3]="Venusaur",[4]="Charmander",
    [5]="Charmeleon",[6]="Charizard",[7]="Squirtle",[8]="Wartortle",
    [252]="Treecko",[253]="Grovyle",[254]="Sceptile",
    [255]="Torchic",[256]="Combusken",[257]="Blaziken",
    [258]="Mudkip",[259]="Marshtomp",[260]="Swampert",
    [261]="Poochyena",[262]="Mightyena",[263]="Zigzagoon",
    [264]="Linoone",[265]="Wurmple",[270]="Lotad",[276]="Taillow",
}

local BATTLE_MENU = {
    [0]="Fight",[1]="Bag",[2]="Pokemon",[3]="Run"
}

local function speak(text)
    local f = io.open(CONFIG.output_file, "a")
    if f then
        f:write(text .. "\n")
        f:close()
    end
end

local function clear_queue()
    local f = io.open(CONFIG.output_file, "w")
    if f then f:close() end
end

local function read8(addr)  return emu:read8(addr)  end
local function read16(addr) return emu:read16(addr) end

local function get_pokemon_name(species_id)
    return POKEMON_NAMES[species_id] or ("Pokemon #" .. species_id)
end

local function handle_battle_start()
    if not CONFIG.announce_battle_start then return end

    local player_hp      = read16(ADDR.player_hp_current)
    local player_hp_max  = read16(ADDR.player_hp_max)
    local player_level   = read8(ADDR.player_level)
    local enemy_level    = read8(ADDR.enemy_level)

    speak("Battle started.")
    speak("Your Pokemon is level " .. player_level ..
          ". HP " .. player_hp .. " of " .. player_hp_max .. ".")
    speak("Enemy is level " .. enemy_level .. ".")

    state.hp_warning_given = false
end

local function handle_hp_changes()
    if not CONFIG.announce_hp_changes then return end

    local player_hp     = read16(ADDR.player_hp_current)
    local player_hp_max = read16(ADDR.player_hp_max)

    if player_hp ~= state.last_player_hp and state.last_player_hp ~= -1 then
        if player_hp < state.last_player_hp then
            speak("HP dropped to " .. player_hp .. ".")
        end

        if player_hp_max > 0 then
            local hp_ratio = player_hp / player_hp_max
            if hp_ratio <= CONFIG.hp_warning_threshold and not state.hp_warning_given then
                speak("Warning. HP critically low. " .. player_hp .. " remaining.")
                state.hp_warning_given = true
            end
        end

        if player_hp == 0 then
            speak("Your Pokemon fainted.")
        end
    end

    state.last_player_hp = player_hp
end

local function handle_menu_reading()
    if not CONFIG.announce_menu then return end

    local selection = read8(ADDR.menu_selection)

    if selection ~= state.last_menu_selection then
        local menu_item = BATTLE_MENU[selection]
        if menu_item then speak(menu_item) end
        state.last_menu_selection = selection
    end
end

callbacks:add("frame", function()
    state.frame_count = state.frame_count + 1

    local current_game_state = read8(ADDR.game_state)

    if current_game_state == 2 and state.last_game_state ~= 2 then
        state.in_battle = true
        handle_battle_start()
    end

    if current_game_state ~= 2 and state.last_game_state == 2 then
        state.in_battle           = false
        state.last_player_hp      = -1
        state.last_enemy_hp       = -1
        state.hp_warning_given    = false
    end

    if state.in_battle and state.frame_count % 30 == 0 then
        handle_hp_changes()
        handle_menu_reading()
    end

    state.last_game_state = current_game_state
end)

clear_queue()
console:log("visual assist loaded")
console:log("speech output: " .. CONFIG.output_file)