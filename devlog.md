# Devlog

## 1. Why I rebuilt the engine

At first, I created three separate standalone scripts that helped three different kinds of players enjoy the game just like everyone else. These scripts were only intended for Pokemon Emerald, but there are many games on mGBA that could use disabled-gamer support. I decided there was no point creating one script for every game. Why not try creating one core engine that, with minimal input, can run accessibility features such as text to speech for any game? As long as the user can provide the profile for the core, it should be able to run for many if not all mGBA games.

## 2. Three regression fixes in the inherited primitives

When I created the core, I created a bunch of primitives, which are essentially actions that the script can run depending on the user's preference. When looking over them I caught some bugs. Decision_timer, which was supposed to pause the game when the user idles for too long, didn't work as intended. In my first iteration, I had designed it so that any button press would take the game out of the idle state, but for the players this was intended for, that wouldn't work. They might be fidgeting with the keyboard or moving around the cursor without making a decision, but that doesn't mean they are ready to decide. So to fix this, I left it up to the user to choose which key they want to press to un-idle. The same kind of issue was with auto-run. Whenever B was pressed the game would start running, but that would be a problem if they pressed B to leave a menu or do something else of that sort. So I changed it so the auto-run feature only injects B when a direction is held. Testing revealed further edge cases though. For example, when the user is in the bag and holding a direction to scroll, the script would inject B and kick them out. So this auto-run feature is a working fix, but not completely finished. The last one is dialogue_advance, which used to pulse with multiple single taps, but now I changed it to hold, pause, then hold again, and only when toggled.

## 3. The battle-flag hunt

When testing the code, I found a major issue. The memory address I was using to check whether the game was in a battle state was incorrect. It kept fluctuating between 0 and 2 in battle, and even outside of battle it read 2. So I went on a memory address hunt to find a suitable address for my needs, and I did find one that consistently reads 0 out of battle and 1 in battle. The thing to learn from this is that memory addresses which fluctuate often, and are so abundant, can only be used after thorough testing.

## 4. The bit shim

When testing the code and injecting the script in mGBA, there was an error where the bit operators weren't working. I assumed mGBA uses the old bit operators, bit.band, bit.bor, and bit.bnot, but it doesn't. I was trying to figure out what could have gone wrong with the bits, because I thought the syntax and logic were fine, but then I read the mGBA version and realized it uses a more updated version. So it was a simple fix, but I learned not to assume anything when working, and to confirm everything so time isn't wasted late into the project. To fix this I created a shim at the top of the file that first checks if the bit library is missing, and if it is, it defines the bit.band, bit.bor, and bit.bnot functions using the native operators (&, |, ~), so the code works without me having to find every bit call and rewrite it with the new syntax.

## 5. Cutting the decision-timer

In this type of game, Pokemon, everything in battle is turn based and the game revolves around the player's actions, so there is no need for a decision timer. There is no time limit when deciding which move to pick or figuring out where to go, so there's no point pausing for idle players. It would be useful in a game like Mario 64, because there the game keeps going even when Mario is idle. He may get hit or lose HP while idle, so a decision_timer would matter there. I decided to scrap it for this game, but it is an upcoming feature I'm planning to build, for the games that actually need it.

## 6. Deferring the menu-cursor reader

I wanted to create a feature for visually impaired players that reads out the menu cursor, but for that I would need a reliable memory address to read the cursor position. It turns out there isn't one. In the game code the cursor seems to act like a 2 by 2 grid, so there aren't simple numbers assigned to it based on which position I'm on. Figuring out how to reliably track the cursor will be its own challenge to come. I'm not scrapping the idea, I just decided to do the other features that are mostly complete first.

## 7. The synchronous-speech limitation

When testing the speech function for the visual profile, there was an error where the speech reader would only read the first line of the first batch of text given to it. It wouldn't read anything after. So to fix that, I decided to create a new speech reader for each batch coming in, but then it would only read the first line of each batch and nothing after. That also wasn't working as intended, so I had to create a new speech reader for each line that gets written into the file Python is reading. This finally worked, but it is a little heavy on the computer, and it is synchronous. It is a blocking call, so the game is sometimes faster than the speech can keep up with. In a turn-based game like Pokemon the game will eventually stop and the speech reader will catch up, but it won't be perfectly synced with the actual in-game text and actions.