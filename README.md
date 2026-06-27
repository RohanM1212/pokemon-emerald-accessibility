# Pokemon Emerald Accessibility Scripts

Scripts that make Pokemon Emerald playable for people with disabilities.

Pokemon Emerald came out in 2005. It has no accessibility settings. If you have a motor impairment, a visual impairment, or a cognitive difference, the game just doesn't care. It throws controls and text at you and expects you to keep up. This project fixes that.

---

## What's In Here

Three separate tracks, each built for a different kind of player.

The motor impairment track is for players who can't hold multiple buttons at the same time. Things like cerebral palsy, limb differences, tremors, or repetitive strain injuries make the standard controls painful or impossible. This script converts those simultaneous presses into single button toggles.

The visual impairment track is for players who can't read the screen clearly enough to play. It reads game memory every frame and writes what's happening to a text file. A Python script picks that up and reads it out loud through your computer speakers.

The cognitive impairment track is for players who get overwhelmed by how fast battles move. If you have ADHD, autism, or just need more time to process what's happening, the game normally doesn't give you that. This script writes plain summaries of what happened each turn, pauses automatically if you freeze on the menu too long, and tracks your move PP so you don't have to.

---

## How It Works Under The Hood

The three scripts above read live game memory through mGBA's Lua scripting API. They watch specific memory addresses every frame and react when values change. No ROM modification needed. Nothing gets saved to your game file.

There is also a core engine in the core folder and game profiles in the games folder. The core is a game-agnostic state machine. It doesn't know what Pokemon is. It just evaluates trigger conditions against memory addresses and fires actions when those conditions are true. The game profiles define what those conditions and actions actually are. If you want to add support for a different GBA game, you only need to create a new profile file. See PORTING.md for how to do that.

---

## How To Use

Download and install mGBA version 0.10 or later from mgba.io. Load your Pokemon Emerald ROM, US version. Go to Tools then Scripting and load whichever script you want. Edit the CONFIG block at the top of the script to turn features on or off.

For the visual impairment track you also need to run speech_reader.py in a terminal while the game is open. Instructions are in the visual-impairment folder.

---

## Testing

Everything here was tested on mGBA 0.10.x with the USA/Europe release of Pokemon Emerald, game code BPEE. Other regions may have different memory addresses and the scripts may not work correctly.

If you have a disability and want to test any of this, open an Issue or reach out directly. Real feedback from real users matters more than anything else here.

---

## Why I Built This

I spent the last couple years teaching myself electronics and programming from scratch. Along the way I started thinking about who gets to benefit from the things people build and who gets left out. Pokemon Emerald has been out for twenty years. Some people never got to finish it because the controls weren't built for them. That seemed like something worth fixing.

I'm also building a free Arduino curriculum for middle schoolers at my local library for the same reason. That project is at github.com/RohanM1212/arduino-for-kids.

---

## License

MIT. Free to use, modify, and share.