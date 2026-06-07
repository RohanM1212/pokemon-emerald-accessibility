# Visual Impairment — Audio Cues for Pokemon Emerald

Part of the [pokemon-emerald-accessibility](https://github.com/RohanM1212/pokemon-emerald-accessibility) project.

---

## Who This Is For

Players with visual impairments who can't read the screen clearly enough to play. This includes low vision, blindness, and anyone who finds the small GBA text difficult to track during fast-paced battles.

---

## What It Does

Pokemon Emerald gives you no audio feedback about what's happening in battle. You have to read everything. This script fixes that by reading the game's memory and speaking game state out loud through your computer's speakers.

When a battle starts, it announces your Pokemon, their level, and their HP. When your HP drops, it tells you. When it gets critical, it warns you. When you navigate the battle menu, it reads your selection out loud.

You don't have to see the screen to know what's happening.

---

## How It Works

Two files work together:

**visual_assist.lua** runs inside mGBA. It reads the game's memory every frame and writes game events to a text file.

**speech_reader.py** runs in the background on your computer. It watches that text file and reads anything new out loud using text-to-speech.

---

## Setup

You need Python installed. Get it at python.org if you don't have it.

Install the required library:

1. Open your terminal and run speech_reader.py first
2. Open mGBA and load Pokemon Emerald (US version)
3. Go to Tools, then Scripting
4. Load visual_assist.lua
5. Start the game

Your computer will start speaking game events as they happen.

---

## What It Announces

- Battle start: your Pokemon name, level, and HP
- Enemy Pokemon name and level
- HP changes during battle
- Critical HP warning at 25% health
- Pokemon fainting
- Battle menu selection when you navigate

---

## Notes

This was built and tested on mGBA 0.10.x with the US release of Pokemon Emerald (game code BPEE). Other regions may have different memory addresses and the script may not work correctly.

The speech output speed can be adjusted in speech_reader.py by changing the rate value. Default is 150 words per minute.

---

## Status

This is the second track in an ongoing project. Motor impairment support is complete. Cognitive assist is coming next.

If you have a visual impairment and want to test this, open an Issue. Real feedback from real users matters more than anything else.