# Pokemon Emerald Accessibility Scripts

Scripts that make Pokemon Emerald playable for people with disabilities.

Pokemon Emerald was released in 2005. It has no accessibility settings. Players with motor impairments, visual impairments, or cognitive differences have had no options until now.

This project builds those options.

---

## Who This Is For

- Players with motor impairments (cerebral palsy, limb differences, tremors, RSI) who struggle with simultaneous button presses
- Players with visual impairments who need audio cues for game state
- Players with cognitive differences (ADHD, autism) who need simplified decision support in battle (coming soon)

---

## Tracks

| Track | Status | Folder |
|-------|--------|--------|
| Motor Impairment | Complete | /motor-impairment/ |
| Visual Impairment | Complete | /visual-impairment/ |
| Cognitive Assist | In Progress | coming soon |

---

## How To Use

1. Download and install mGBA (version 0.10 or later) at mgba.io
2. Load your Pokemon Emerald ROM (US version)
3. Go to Tools, then Scripting
4. Click Load Script and select the .lua file for the track you want
5. Edit the CONFIG block at the top of the script to turn features on or off

For the visual impairment track, you also need to run speech_reader.py in the background. Full instructions are in the visual-impairment folder.

---

## Testing

Scripts tested on mGBA 0.10.x with the US release of Pokemon Emerald (game code BPEE).

If you have a disability and want to test these scripts, open an Issue or reach out. Real feedback from real users is what makes this project better. Your experience matters more than any amount of my own testing.

---

## Contributing

Pull requests welcome. If you want to add support for a new disability or a new feature, open an Issue first so we can talk through the approach.

---

## Why I Built This

I spent the last several months teaching myself electronics and programming. Along the way I started noticing that helping people isn't just about giving them the same opportunities to learn. It's about giving them the same opportunities to experience things they should have been able to experience all along.

Pokemon Emerald came out in 2005. People have been playing it for over 20 years. Some of them never got to finish it because the controls weren't built for them. That seemed like something worth fixing.

I'm also building a free Arduino curriculum for middle schoolers at my local library for the same reason. If you're curious about that project it's at github.com/RohanM1212/arduino-for-kids.

---

## License

MIT, free to use, modify, and share.