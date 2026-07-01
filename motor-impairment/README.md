# Motor Impairment — One-Handed Play for Pokemon Emerald

Part of the [pokemon-emerald-accessibility](https://github.com/RohanM1212/pokemon-emerald-accessibility) project.

>**Status: planned, not yet built.** 

>The engine already supports the actions this track needs (a run-button toggle and hold-to-advance dialogue), but the Pokemon Emerald profile for motor play has not been written or tested yet. This README describes the intended design, not a working track.

---

## Who This Is For

Players with a motor impairment affecting one hand, including cerebral palsy, tremors, or injuries that make holding multiple buttons at once difficult.

---

## Planned Features

Running in Pokemon Emerald normally means holding B the whole time you move. The plan is to turn that into a toggle: press SELECT once and your character keeps running until you press it again. The engine's auto_run action already does this, so the remaining work is a game profile plus finding and verifying the right memory addresses for this version of the game.

The second planned feature is hold-to-advance dialogue: instead of tapping A
repeatedly through long text, you hold it and the script taps for you. The
engine's dialogue_advance action already supports this.

---

## Why It Isn't Done

This track injects button presses and depends on memory addresses that haven't been verified yet, so it needs live testing before it can be called working. It was scoped as future work so the visual and cognitive tracks could be finished and verified first.
An early prototype (one_handed_assist.lua) is in this folder, but it is unverified and was created before the engine. The real motor track will be a profile built on the core, like the visual and cognitive tracks.