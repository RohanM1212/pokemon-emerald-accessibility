--[[
    accessibility_core.lua
    the thing is, my first design was still too hooked on pokemon logic. I had
    hardcoded the number two for combat state, and assumed every game has health
    bars and a player versus enemy setup. that is a bad trap.

    now, this core engine is completely blind to what game is running. it doesn't
    know what a battle is, what a menu is, or what the B button does. it is just
    a state machine. the game profile passes named states, triggers, and actions.
    the core spins the wheels, reads memory, evaluates the rules, and fires actions.

    fixed: every execute_action branch now explicitly returns output_keys so we
    never accidentally pass nil into a bit operation and crash the whole thing.
--]]

local core = {}

-- internal tracker for the state engine
local state = {
    frame_count    = 0,
    current_states = {},   -- which named states are active right now
    last_keys      = 0,

    -- separate storage blocks per action type so they don't stomp each other
    hp_monitor    = {},
    hp_summary    = {},
    decision_timer = {},
    auto_run      = { toggle = false, select_was_pressed = false }
}

local ADDR   = {}
local STATES = {}
local CONFIG = {}

local function read8(addr)  return emu:read8(addr)  or 0 end
local function read16(addr) return emu:read16(addr) or 0 end

local function write_to_queue(queue_name, message)
    -- nothing happens if the profile forgot to define this queue
    if not CONFIG.queues or not CONFIG.queues[queue_name] then return end
    local filepath = CONFIG.queues[queue_name]
    local f = io.open(filepath, "a")
    if f then
        f:write(message .. "\n")
        f:close()
    end
end

local function evaluate_trigger(trigger)
    if not trigger or not trigger.address then return false end
    local raw_addr = ADDR[trigger.address]
    if not raw_addr then return false end

    local val    = read8(raw_addr)
    local target = trigger.value

    if trigger.operator == "eq"  then return val == target end
    if trigger.operator == "neq" then return val ~= target end
    return false
end

-- the six supported action primitives
local function execute_action(act, current_keys)
    local output_keys = current_keys
    local btn_map     = CONFIG.buttons or {}

    if act.action == "speak" then
        -- on_enter and on_exit only fire once so we just write immediately
        write_to_queue(act.queue or "speech", act.text)
        return output_keys

    elseif act.action == "monitor_hp" then
        -- only poll every 30 frames so we don't spam the queue file
        if state.frame_count % 30 ~= 0 then return output_keys end

        local hp_addr  = ADDR[act.address]
        local max_addr = ADDR[act.max_address]
        if not hp_addr or not max_addr then return output_keys end

        local current_hp = read16(hp_addr)
        local max_hp     = read16(max_addr)

        local id = act.address
        if not state.hp_monitor[id] then
            state.hp_monitor[id] = { last_hp = -1, warning_given = false }
        end
        local store = state.hp_monitor[id]

        if current_hp ~= store.last_hp and current_hp > 0 then
            write_to_queue(act.queue, "Your HP is now " .. current_hp)
            local threshold = max_hp * (CONFIG.hp_warning_threshold or 0.25)
            if current_hp <= threshold and not store.warning_given then
                write_to_queue(act.queue, "Warning. HP critically low. " .. current_hp .. " remaining.")
                store.warning_given = true
            end
        end
        if current_hp == 0 and store.last_hp > 0 then
            write_to_queue(act.queue, "Your combatant fainted.")
        end
        store.last_hp = current_hp
        return output_keys

    elseif act.action == "decision_timer" then
        local menu_addr = ADDR[act.menu_address]
        if not menu_addr then return output_keys end

        local id = act.menu_address
        if not state.decision_timer[id] then
            state.decision_timer[id] = { inactive_frames = 0 }
        end
        local store = state.decision_timer[id]

        -- 0x03FF catches directions, A, B, Select, and Start all at once
        local is_moving = (bit.band(current_keys, 0x03FF) ~= 0)
        if is_moving then
            store.inactive_frames = 0
        else
            store.inactive_frames = store.inactive_frames + 1
        end

        local max_frames = (CONFIG.timer_seconds or 5) * 60
        if store.inactive_frames >= max_frames then
            -- what I found is that sending a real START tap is more stable
            -- than calling emu:pause() directly. keeps the script alive too.
            local start_mask = btn_map["START"] or 0x0008
            output_keys = bit.bor(output_keys, start_mask)
            store.inactive_frames = 0
        end
        return output_keys

    elseif act.action == "summarize_hp" then
        if state.frame_count % 30 ~= 0 then return output_keys end

        local p_addr = ADDR[act.player_address]
        local e_addr = ADDR[act.enemy_address]
        if not p_addr or not e_addr then return output_keys end

        local p_hp = read16(p_addr)
        local e_hp = read16(e_addr)

        local id = act.player_address .. "_" .. act.enemy_address
        if not state.hp_summary[id] then
            state.hp_summary[id] = { last_p = -1, last_e = -1 }
        end
        local store = state.hp_summary[id]

        if p_hp ~= store.last_p or e_hp ~= store.last_e then
            local summary = string.format("State: Player %d | Enemy %d", p_hp, e_hp)
            write_to_queue(act.queue, summary)
            store.last_p = p_hp
            store.last_e = e_hp
        end
        return output_keys

    elseif act.action == "auto_run" then
        local run_btn_mask = btn_map[act.button] or 0x0002
        local select_mask  = btn_map["SELECT"]   or 0x0004

        local select_pressed     = (bit.band(current_keys, select_mask) ~= 0)
        local select_was_pressed = state.auto_run.select_was_pressed

        -- only toggle on a fresh press, not while held
        if select_pressed and not select_was_pressed then
            state.auto_run.toggle = not state.auto_run.toggle
        end
        state.auto_run.select_was_pressed = select_pressed

        if state.auto_run.toggle then
            output_keys = bit.bor(output_keys, run_btn_mask)
        end
        return output_keys

    elseif act.action == "dialogue_advance" then
        local a_mask    = btn_map[act.button] or 0x0001
        local a_pressed = (bit.band(current_keys, a_mask) ~= 0)
        if a_pressed then
            if state.frame_count % 4 == 0 then
                output_keys = bit.bor(output_keys, a_mask)
            else
                output_keys = bit.band(output_keys, bit.bnot(a_mask))
            end
        end
        return output_keys
    end

    -- unknown action type, pass keys through unchanged
    return output_keys
end

function core.init(addresses, states, config)
    ADDR   = addresses
    STATES = states
    CONFIG = config

    callbacks:add("frame", function()
        state.frame_count = state.frame_count + 1
        local current_keys  = emu:getKeys()
        local modified_keys = current_keys

        for state_name, state_def in pairs(STATES) do
            local is_triggered  = evaluate_trigger(state_def.trigger)
            local was_triggered = state.current_states[state_name] or false

            if is_triggered and not was_triggered then
                state.current_states[state_name] = true
                if state_def.on_enter then
                    for _, act in ipairs(state_def.on_enter) do
                        modified_keys = execute_action(act, modified_keys)
                    end
                end

            elseif not is_triggered and was_triggered then
                state.current_states[state_name] = false
                if state_def.on_exit then
                    for _, act in ipairs(state_def.on_exit) do
                        modified_keys = execute_action(act, modified_keys)
                    end
                end

                -- wipe the per-state storage when a state goes inactive
                -- so stale HP values don't carry over into the next session
                state.hp_monitor    = {}
                state.hp_summary    = {}
                state.decision_timer = {}
            end

            if state.current_states[state_name] and state_def.while_active then
                for _, act in ipairs(state_def.while_active) do
                    modified_keys = execute_action(act, modified_keys)
                end
            end
        end

        state.last_keys = current_keys
        emu:setKeys(modified_keys)
    end)
end

return core