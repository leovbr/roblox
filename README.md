# Leo Roblox Project

Core gameplay foundation for the Leo Roblox brainrot-style experience.

## Current systems

- Procedural starter map and spawn
- 12 zones with normal, special, mythic and secret progression hooks
- 5 starting egg slots
- Hatchable eggs with zone-gated rarity rolls
- Brainrot inventory
- Passive brainrot income
- Cash leaderstats
- Treadmill speed progression
- Cage/slot, speed and aura upgrade hooks
- Day/night cycle
- Safe-zone / stealing gameplay hooks
- Mobile-friendly HUD
- Rojo project mapping via `default.project.json`

## Studio setup

The repository contains the source structure; Roblox Studio still needs to be used to run/test the experience.

If using Rojo, open `default.project.json` and sync the project into Studio.

Without Rojo, copy the scripts under `src/ServerScriptService` into `ServerScriptService`, and `src/StarterPlayer/StarterPlayerScripts/MainUI.client.lua` into `StarterPlayer > StarterPlayerScripts`.

## Core gameplay loop

1. Spawn in the safe area.
2. Move through unlocked zones.
3. Approach an egg and hold the Hatch prompt.
4. Spend cash to hatch a random brainrot tier.
5. Brainrots generate passive cash.
6. Upgrade slots, speed and aura.
7. Progress toward higher zones and rarer brainrots.
8. Expand the stealing, guard, trap and base systems as the game grows.
