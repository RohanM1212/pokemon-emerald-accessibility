# Cognitive Accessibility — Battle Summaries and Decision Pausing for Pokemon Emerald

Part of the [pokemon-emerald-accessibility](https://github.com/RohanM1212/pokemon-emerald-accessibility) project.

---

## Who This Is For

Players with ADHD, autism, processing disorders, or anyone who gets totally overwhelmed by how fast Pokemon battles happen. If you struggle with information overload, the game doesn't really care and just throws text lines at you before they disappear instantly.

---

## What It Does

This script watches the battle and writes down exactly what happened into a file named cognitive_queue.txt. It says things like how much HP you lost or what the enemy did. It leaves it there so you can read it at your own speed.

There is also a timer feature. If you are sitting on the fight menu trying to choose a move and you freeze for 5 seconds, the script hits the START button for you to pause the game. It takes away the rush.

It also tracks your moves. When you hover over a move, it reads the name and how much PP is left so you don't have to track it in your head. If the background noise bothers you, you can turn on the distraction setting to shut off the other audio queues entirely so only the battle summary plays.

---

## How To Use

Open mGBA and boot up Pokemon Emerald. Go to Tools then Scripting and load this file. You can change the paths or the timer length by opening the file in a text editor and changing the values at the top.

---

## Notes

This works on the USA/Europe version of the ROM. The game code is BPEE. If you use a different version, the numbers I used to find the PP values in the memory won't line up and it will read random garbage.

If you have a cognitive disability and want to test this, open an Issue. Real feedback is the only way to know if this actually helps.