# Visual Impairment — Audio Cues for Pokemon Emerald

Part of the [pokemon-emerald-accessibility](https://github.com/RohanM1212/pokemon-emerald-accessibility) project.

---

## Who This Is For

Blind or visually impaired players who can't see what is happening on screen during battles.

---

## What It Does

This script watches the game's memory during battle. It announces when a battle starts and ends, and it tracks your HP, speaking the new value whenever it changes. If your HP drops below twenty-five percent it gives a low-HP warning, and it tells you when your Pokemon faints.

It writes each of these events as text to a file called speech_queue.txt. A separate Python script, speech_reader.py, watches that file and reads each line out loud using a text-to-speech engine.

---

## How To Use

You need two things running at the same time. First, load the visual profile inside mGBA through Tools then Scripting. Second, run speech_reader.py in a terminal. Both files must point to the same speech_queue.txt path or they won't talk to each other.

---

## Known Limitations

Speech is synchronous, so in a very fast sequence of events the narration can lag slightly behind the game. This is fine for a turn-based game like Pokemon.

Menu narration (reading out Fight, Bag, Pokemon, Run as you move the cursor) is planned but not built yet. The battle menu cursor is stored as a 2x2 grid position rather than a simple counter, so it needs more reverse-engineering to read reliably.

---

## Notes

I had to re-find the battle-state memory address because my first one was wrong. It read the same value in and out of battle, so it triggered constantly. The address used now is verified for the USA/Europe Emerald ROM, game code BPEE.

If you have a visual impairment and want to test this, open an Issue. Real feedback is what makes this actually useful.