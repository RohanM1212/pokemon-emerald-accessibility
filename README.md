# Pokemon Emerald Accessibility Scripts

A reusable accessibility engine, with profiles for specific needs.

Pokemon Emerald came out in 2005. It has no accessibility settings. If you have a motor impairment, a visual impairment, or a cognitive difference, the game just doesn't care. It throws controls and text at you and expects you to keep up. This project fixes that.

---

## What's In Here

Two complete tracks, and one planned.

The motor impairment track is for players who can't hold multiple buttons at the same time. Things like cerebral palsy, limb differences, tremors, or repetitive strain injuries make the standard controls painful or impossible. This is a planned script, which will have features such as converting simultaneous presses into single button toggles.

The visual impairment track is for players who can't read the screen clearly enough to play. It reads game memory every frame and writes what's happening to a text file. A Python script picks that up and reads it out loud through your computer speakers.

The cognitive impairment track is for players who get overwhelmed by how fast battles move. If you have ADHD, autism, or all the text on the screen is too fast for you to process, the game doesn't have settings to adjust those. This script writes plain summaries of what happened each turn. I am planning to add more features such as move and PP summaries and pausing the game when inactive for too long.

---

## How It Works Under The Hood

Two of the tracks above have complete profiles which use the core engine for working as intended. The profiles provide the memory addresses, actions, and configurations for the core to run how each specific profile intends.

There is also a core engine in the core folder and game profiles in the games folder. The core is a game-agnostic state machine. It doesn't know what Pokemon is. It just evaluates trigger conditions against memory addresses and fires actions when those conditions are true. The game profiles define what those conditions and actions actually are. If you want to add support for a different GBA game, you only need to create a new profile file. See PORTING.md for how to do that.

---

## How To Use

Download and install mGBA version 0.10 or later from mgba.io. Load your Pokemon Emerald ROM, US/Europe version. Go to Tools then Scripting and load either the cognitive profile, or the visual profile. They work as is, but if you want the script to do something specific that it doesn't already do when the state is activated, you can change those things in the profile.

---

## Testing

The visual and cognitive tracks were tested on mGBA 0.10.x with the USA/Europe release (game code BPEE). Other regions may have different memory addresses and the scripts may not work correctly.

If you have a disability and want to test any of this, open an Issue or reach out directly. Real feedback from real users matters more than anything else here.

---

## Why I Built This

I spent the last couple years teaching myself electronics and programming from scratch. Along the way I started thinking about who gets to benefit from the things people build and who gets left out. There are some accessibility tools for older Pokemon games, but they tend to be built for one specific game on older emulators, and mostly for screen-reader users. I wanted to try something more general: one engine that could bring visual, cognitive, and motor support to modern mGBA, where adding a new game is just a new profile instead of a whole new script. That felt like a problem worth working on.

---

## License

MIT. Free to use, modify, and share.