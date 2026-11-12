# Gothic 1 Remake: Whole Vein Mining

A small script-only mod for Gothic 1 Remake: one dig moves all the ore left in a vein to your inventory, except the last piece. The next dig gives the last piece, so a vein takes two digs (15 ore: 14, then 1).

Turn it off in `Settings > Game > Whole Vein Mining`.

## How it works

The mod replaces the hero's mining ability with a subclass. When a dig starts, it moves all ore but one piece from the vein to the hero. The game's own dig gives nothing more in that dig; the last piece comes with the next dig, as in the unmodded game. If the game's dig ever gives more than what left the vein, the extra is taken back.

## Install

1. Copy the `WholeVeinMining` folder to `G1R/Mods` in the game's install folder.
2. Enable the mod in the game's mod manager (launch option `-ModManagementUI`).

No UE4SS or other loader is needed. Loading an older save shows the game's different-modlist warning, as with any mod.

This is an unofficial modification. It is not made, endorsed or supported by THQ Nordic.
