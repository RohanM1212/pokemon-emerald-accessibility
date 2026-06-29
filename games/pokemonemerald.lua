--[[
    pokemon_emerald.lua
    what I found out after doing this raw is that managing profiles is way cleaner
    than keeping game logic inside the engine. this file just holds the raw memory
    layout for emerald and the state machine rules, then kicks it all over to the core.
--]]

local core = require("core/accessibility_core")

local CONFIG = {
    hp_warning_threshold = 0.25,
    timer_seconds        = 5,
    queues = {
        speech    = "speech_queue.txt",
        cognitive = "cognitive_queue.txt"
    },
    buttons = {
        A      = 0x0001,
        B      = 0x0002,
        SELECT = 0x0004,
        START  = 0x0008
    }
}

-- confirmed by live memory scanning on the USA Pokemon Emerald ROM (game code BPEE)
local EMERALD_ADDR = {
    game_state        = 0x02024064,  -- 8-bit, 2 = battle
    player_hp_current = 0x020240AC,  -- 16-bit
    player_hp_max     = 0x02024544,  -- 16-bit
    player_level      = 0x02024540,  -- 8-bit
    enemy_hp_current  = 0x0202479A,  -- 16-bit
    enemy_hp_max      = 0x0202479C,  -- 16-bit
    enemy_level       = 0x02024798,  -- 8-bit
    menu_selection    = 0x02023340,  -- 8-bit
}

local STATES = {
    battle = {
        trigger = {
            address  = "game_state",
            operator = "eq",
            value    = 2
        },
        on_enter = {
            { action = "speak", text = "Battle started.", queue = "speech" }
        },
        on_exit = {
            { action = "speak", text = "Battle ended.", queue = "speech" }
        },
        while_active = {
            { action = "monitor_hp",     address = "player_hp_current", max_address = "player_hp_max", queue = "speech" },
            { action = "decision_timer", menu_address = "menu_selection", queue = "cognitive" },
            { action = "summarize_hp",   player_address = "player_hp_current", enemy_address = "enemy_hp_current", queue = "cognitive" }
        }
    },
    overworld = {
        trigger = {
            address  = "game_state",
            operator = "neq",
            value    = 2
        },
        while_active = {
            { action = "auto_run",         button = "B" },
            { action = "dialogue_advance", button = "A" }
        }
    }
}

console:log("==============================================")
console:log("Profile Loaded: Pokemon Emerald (USA)")
console:log("State Machine Active in Core Engine")
console:log("==============================================")

core.init(EMERALD_ADDR, STATES, CONFIG)