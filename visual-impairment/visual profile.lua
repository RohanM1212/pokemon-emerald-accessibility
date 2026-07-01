--[[
    visual_profile.lua
    A profile for the accessibility engine. It reads Pokemon Emerald's battle
    state and speaks it aloud for players who can't see the screen clearly.

    This also works as a template. To adapt the engine to another game, copy
    this file and change the addresses, the states, and the config. The engine
    itself never changes.
--]]

local core = require("accessibility_core")

-- name -> real memory location. these are for Pokemon Emerald US (BPEE),
-- verified by live memory scanning. for another game, these are the values
-- you find and replace, everything else can stay the same.
local addresses = {
    battle_flag       = 0x0300090E,  -- 1 in battle, 0 out, verified through a full turn
    player_hp_current = 0x020240AC,  -- 16-bit
    player_hp_max     = 0x02024544,  -- 16-bit
    player_level      = 0x02024540,  -- 8-bit
    enemy_hp_current  = 0x0202479A,  -- 16-bit
    enemy_hp_max      = 0x0202479C,  -- 16-bit
    enemy_level       = 0x02024798,  -- 8-bit
    -- menu cursor address not yet found, see future work
}

-- available actions you can put in the lists above:
--   speak        - say a fixed line of text
--   announce     - read a memory value aloud when it changes (optional labels table)
--   monitor_hp   - watch an HP value, announce changes and a low-HP warning
--   summarize_hp - announce player and enemy HP together
--   decision_timer  - pause the game if the player freezes on a menu
--   auto_run     - toggle a held button on/off (motor assist)
--   dialogue_advance - hold a button to auto-tap through text (motor assist)
--   clear_queue  - wipe a queue file (for reduced-distraction mode)


-- what to detect and what to do in each state
local states = {
    in_battle = {
        -- battle_flag reads 1 means we're in a battle
        trigger = { address = "battle_flag", operator = "eq", value = 1 },

        -- fires once when the battle starts
        on_enter = {
            { action = "speak", text = "Battle started.", queue = "speech" },
        },

        -- fires every frame the battle is active
        while_active = {
            { action = "monitor_hp", address = "player_hp_current", max_address = "player_hp_max", queue = "speech" },
        },

        -- fires once when the battle ends
        on_exit = {
            { action = "speak", text = "Battle ended.", queue = "speech" },
        },
    },
}

-- file paths, thresholds, and the button map
local config = {
    queues = {
        speech = "C:/Users/rmukh/Desktop/pokemon-accessibility-dev/speech_queue.txt",
    },
    hp_warning_threshold = 0.25,
    buttons = {
        A = 1, B = 2, SELECT = 4, START = 8,
        RIGHT = 16, LEFT = 32, UP = 64, DOWN = 128, R = 256, L = 512,
    },
}

-- hand the three tables to the engine and start it
core.init(addresses, states, config)

console:log("visual profile loaded")