# Gothic 1 Remake: Whole Vein Mining

A small script-only mod for Gothic 1 Remake: one dig empties the whole ore vein, and all the ore that was left in it goes to your inventory. The dig animation plays once, as usual.

Turn it off in `Settings > Game > Whole Vein Mining`.

## How it works

The mod replaces the hero's mining ability with a subclass. When a dig starts, it moves all ore but one piece from the vein to the hero. The game's own dig then takes the last piece, so the vein empties the way it normally does. If the game's dig ever gives more than what was left, the extra is taken back.

## Install

1. Copy the `WholeVeinMining` folder to `G1R/Mods` in the game's install folder.
2. Enable the mod in the game's mod manager (launch option `-ModManagementUI`).

No UE4SS or other loader is needed. Loading an older save shows the game's different-modlist warning, as with any mod.

Unofficial fan mod, not affiliated with the game's developers or publisher.
