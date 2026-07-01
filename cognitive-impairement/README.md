# Cognitive Accessibility — Battle Summaries for Pokemon Emerald

Part of the [pokemon-emerald-accessibility](https://github.com/RohanM1212/pokemon-emerald-accessibility) project.

---

## Who This Is For

Players with ADHD, autism, processing disorders, or anyone who gets totally overwhelmed by how fast Pokemon battles happen. If you struggle with information overload, the game doesn't really care and just throws text lines at you before they disappear instantly.

---

## What It Does

This script watches the battle and writes down exactly what happened into a file named speech_queue.txt. It says things like how much HP you lost. It leaves it there so you can read it at your own speed. Sometimes the pokemon games assume you can read very fast, so if needed this is there to help anyone who needs help with keeping up with the game speed.

---

## Planned

Planned features: a move and PP readout, and other summary options. A decision-pause timer was prototyped but cut, because in a turn-based game the battle menu already waits for you, so pausing added nothing.

---

## How To Use

Open mGBA and boot up Pokemon Emerald. Go to Tools then Scripting and load cognitive profile. This is a pre-built profile/template that uses the engine core to read out battle summaries and such.

---

## Notes

This works on the USA/Europe version of the ROM. The game code is BPEE. If you use a different version, the numbers I used to find the HP values in the memory won't line up and it will read random stuff.

If you have a cognitive disability and want to test this, open an Issue. Real feedback is the only way to know if this actually helps.