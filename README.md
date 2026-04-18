# Pokemon Emerald Accessibility Scripts

Scripts that make Pokemon Emerald playable for people with disabilities.

Pokemon Emerald was released in 2005. It has no accessibility settings. Players with motor impairments, visual impairments, or cognitive differences have had no options — until now.

This project builds those options.

---

## Who This Is For

- Players with **motor impairments** (cerebral palsy, limb differences, tremors, RSI) who struggle with simultaneous button presses
- Players with **visual impairments** who need audio cues for game state *(coming soon)*
- Players with **cognitive differences** (ADHD, autism) who need simplified decision support in battle *(coming soon)*

---

## Current Scripts

### Motor Impairment — One-Handed Play
**Folder:** `/motor-impairment/`

Pokemon Emerald requires holding B while pressing a direction to run. It requires rapid repeated A presses to advance dialogue. These are impossible or painful for many one-handed players.

**This script fixes that:**
- **Auto-Run Toggle** — press SELECT once to toggle running on/off. No need to hold B.
- **Dialogue Auto-Advance** — hold A and text advances automatically. No repeated tapping.
- **Debug Overlay** — shows script status in the mGBA console so you always know what's active.

---

## How To Use

1. Download and install [mGBA](https://mgba.io/) (version 0.10 or later)
2. Load your Pokemon Emerald ROM (US version)
3. Go to **Tools → Scripting**
4. Click **Load Script** and select the `.lua` file for the feature you want
5. Edit the `CONFIG` block at the top of the script to turn features on or off

---

## Coming Soon

| Track | Status | What it does |
|-------|--------|--------------|
| Visual Impairment | Planned | Audio cues for battle state, HP levels, and map transitions |
| Cognitive Assist | Planned | Battle move suggestions, simplified menus, attention reminders |

---

## Testing

These scripts were tested using mGBA 0.10.x with the US release of Pokemon Emerald (game code: BPEE).

If you have a disability and want to test these scripts, please open an Issue or reach out. Real user feedback is what makes this project better. Your experience matters more than any amount of my own testing.

---

## Contributing

Pull requests welcome. If you want to add support for a new disability or a new feature, open an Issue first so we can discuss the approach.

---

## Why I Built This

I've spent the last 1-2 years learning electornics and coding. After I met some people and realised that not everyone is as privileged as me, I made it my mission to try and give the same oppurtunities and experiences to the underprivileged. 

I already am in the process of building a cirriculumn teaching Arduino, accessible to annyone with or without physical parts. While playing pokemon, I realised that helping the underprivileged is not just about giving them the same opportunities to learn, its also about giving them the same opportunities to experience what they deserve to experience.

This is an ongoing project. I hope you can support me to make it as big and wide reaching, so anybody can play pokemon emerald.

---

## License

MIT — free to use, modify, and share.
