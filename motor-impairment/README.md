# Motor Impairment — One-Handed Play for Pokemon Emerald

Part of the [pokemon-emerald-accessibility](https://github.com/RohanM1212/pokemon-emerald-accessibility) project.

---

## Who This Is For

Players who have a motor impairment affecting one hand, including things like cerebral palsy, tremors, or injuries that make holding multiple buttons at the same time impossible.

---

## What It Does

The main issue in Pokemon Emerald is that you have to hold the B button down the entire time you want to run. What I did here was change that into a toggle. You press SELECT once and your character keeps running until you hit it again.

I also added a part that fixes dialogue. Instead of smashing the A button a million times during long talking scenes, you just hold it down and the text advances itself. It saves your wrists from getting tired.

---

## How To Use

Open your mGBA emulator and load the game. Click on Tools and then Scripting. Load this script file. If you want to shut off the text helper or the run toggle, open the script in a text editor and flip the true values to false at the top.

---

## Notes

I built this using the standard USA/Europe Pokemon Emerald ROM. The memory locations for checking if you are moving or talking are set for that specific version.

If you have a motor impairment and want to test this, open an Issue. Real feedback from real users is what makes this project better.