# Visual Impairment — Audio Cues for Pokemon Emerald

Part of the [pokemon-emerald-accessibility](https://github.com/RohanM1212/pokemon-emerald-accessibility) project.

---

## Who This Is For

Blind or visually impaired players who can't read the game menus or see what is happening on screen during battles.

---

## What It Does

This script constantly checks the game memory every thirty frames. It looks for changes in your health points and what options you are hovering over. When something changes, it writes the text out to a file called speech_queue.txt.

There is also a Python script called speech_reader.py that watches that file and reads it out loud using a text-to-speech engine. If your HP drops below twenty-five percent, it sounds a warning so you know you are about to faint. When you move up and down in the battle menu, it says FIGHT or BAG out loud before you click it.

---

## How To Use

You need two things running at the same time. First, load this script inside mGBA by going to Tools and then Scripting. Second, run speech_reader.py using Python on your computer. Make sure the file paths inside both files point to the same location or they won't talk to each other.

---

## Notes

I had to redo the memory addresses from my first version because the original ones were wrong. These are verified for the USA/Europe version of the Emerald ROM, game code BPEE.

If you have a visual impairment and want to test this, open an Issue. Real feedback is what makes this actually useful.