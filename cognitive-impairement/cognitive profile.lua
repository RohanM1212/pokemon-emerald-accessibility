--[[
    cognitive_profile.lua
    A profile for players who get overwhelmed by fast battles or too much to track.
    It speaks a short player-vs-enemy HP summary when things change, so the state
    of the battle is always available in one simple readout.

    Same engine as the visual profile, just a different set of states and actions.
    That is the whole point of the engine: new need, new profile, no new core.
--]]

local core = require("accessibility_core")

-- only the addresses this track actually uses
local addresses = {
    battle_flag       = 0x0300090E,  -- 1 in battle, 0 out, verified through a full turn
    player_hp_current = 0x020240AC,  -- 16-bit
    enemy_hp_current  = 0x0202479A,  -- 16-bit
}

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
            -- one simple readout of both HP bars when either changes
            { action = "summarize_hp", player_address = "player_hp_current", enemy_address = "enemy_hp_current", queue = "speech" },
        },

        -- fires once when the battle ends
        on_exit = {
            { action = "speak", text = "Battle ended.", queue = "speech" },
        },
    },
}

-- one shared speech queue. same Python reader as the visual track.
local config = {
    queues = {
        speech = "C:/Users/rmukh/Desktop/pokemon-accessibility-dev/speech_queue.txt",
    },
    buttons = {
        A = 1, B = 2, SELECT = 4, START = 8,
        RIGHT = 16, LEFT = 32, UP = 64, DOWN = 128, R = 256, L = 512,
    },
}

core.init(addresses, states, config)
console:log("cognitive profile loaded")