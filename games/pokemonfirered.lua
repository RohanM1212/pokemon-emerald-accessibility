--[[
    pokemon_firered.lua
    same decoupled layout as the emerald profile. the core doesn't care about
    the offsets, it just evaluates whatever rules get passed in below.

    NOTE: this profile is a starting point only. every single address in
    FIRERED_ADDR needs live memory verification before use. the coordinates
    below came from public offset research but I haven't scanned them myself
    against a live Fire Red ROM yet. use PORTING.md to verify them before
    you load this into a real session.
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

-- targeted EWRAM offsets for Pokemon Fire Red USA (game code BPRE)
-- every address below is UNVERIFIED and needs memory scanning before use
local FIRERED_ADDR = {
    game_state        = 0x02023B44,  -- UNVERIFIED
    player_hp_current = 0x020242B4,  -- UNVERIFIED
    player_hp_max     = 0x020242B6,  -- UNVERIFIED
    player_level      = 0x020242BA,  -- UNVERIFIED
    enemy_hp_current  = 0x02024364,  -- UNVERIFIED
    enemy_hp_max      = 0x02024366,  -- UNVERIFIED
    enemy_level       = 0x0202436A,  -- UNVERIFIED
    menu_selection    = 0x02023D74,  -- UNVERIFIED
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
console:log("Profile Loaded: Pokemon Fire Red (USA - BPRE)")
console:log("WARNING: Addresses unverified. Verify before use.")
console:log("==============================================")

core.init(FIRERED_ADDR, STATES, CONFIG)