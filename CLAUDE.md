# Gothic 1 Remake: Whole Vein Mining

Script-only ModKit mod. `WholeVeinMining/` is the mod package; only that folder goes to `G1R/Mods`.

## Rules

- **No spoilers.** Vatra is playing the game for the first time. Game scripts, docs and sample mods contain character, quest, place and chapter names. Never write those in chat, commits or files unless Vatra mentioned them first. Use UI names and general words ("ore vein").
- Repo content (code, README, commits) is in English. Chat with Vatra is in Croatian.
- Writing outside `~/github` needs Vatra's explicit yes each time. This includes copying to `G1R\Mods`, launch options, `Mods.ini` and other mods in Vortex.
- Don't publish the mod to Nexus or Steam Workshop.
- Only Vatra can confirm the mod works, by seeing it in his game.
- Scope is one dig takes all ore but the last piece, with an on/off switch. The last piece needs a second dig; Vatra accepted that on 2026-11-07. No speed, yield or other changes unless Vatra asks.
- Other mods' code is a reference only: don't copy it without checking its license.
- Game behavior claims come from the shipped scripts (`G1R/Script`) or the ModKit reference, not from memory. Mining itself is native code; scripts only see `UMiningConfig` values and the vein's container.
