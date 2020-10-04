# NPCs Go Home #

A no-longer-lightweight fork of [OEA's Lightweight Lua Scheduling](https://www.nexusmods.com/morrowind/mods/48584) version 1.1 (I implemented most of the changes from 1.2 though)

## Things I've Added, Changed or Fixed ##

### The "Big" Stuff ###

- NPC "homes"
  - Outside NPCs who have homes (local cell that contains their name, i.e.: NPC Fargoth and cell "Seyda Neen, Fargoth's House") are currently paired with the inside cell of their home
  - Other NPCs are configurably paired with local public houses (Inns, temples, and guildhalls of their faction)
- Option to move NPCs into their home rather than disable them
    - Working on a better variety of positions in cells
- Moved NPCs persist on save/load

### Other Stuff ###

- Timer for updating everything, configurable interval
- Disabled NPCs are reenabled even if the option to disable NPCs is off
- Silt Striders and pack guars are disabled as well
- Inclement weather toggle removed, in favour of dropdown with "None" option
- Travel agents, their silt striders, and configured races/classes optionally stay in inclement weather
- When locking doors, cells that contain NPCs of any class on the ignore list are left alone
  - Cells that are >= 75% (configurable) one faction will be public, if that faction is on the ignore list
  - Additionally, NPCs in those cells can still be interacted with
- Cells with no NPCs are not locked
- Ignore list now supports NPC class and faction. Any interior cell with an NPC of
  ignored class or faction will not be locked, or have its NPCS disabled.
- Cells of player joined factions are not locked

### Debug / Devel Stuff ###

- data/positions.lua contains positions used for NPC placement in homes and public houses
- it's tedious work, so I haven't done many, so I've added debug some debug keybinds to help:
  - ctrl + c prints to mwse.log position data sorta properly formatted for positions.lua
  - alt + c prints to mwse.log all the current runtime data, found in common.runtimeData
    - includes: public houses and homes found for NPCs: cells that NPCs will be moved to, needing position data

## WIP ##

- Currently NPCs without a home are moved into local cells with matching faction, or a random public cell
- NPCs are classed based on the worth of their equipped items, and inventory
  - NPC worth is a table of: equipped items worth, inventory items worth, barter
    gold and if a merchant with a cell, the worth of items in containers in that
    cell that the NPC sells is added, and the total of all calculated values
- Public houses are classed based on the worth of NPCs in the cell

## TODO ##

- Move non-faction NPCs who don't have homes to temples or inns based on their "worth"
- Pick temple for the poorest NPCs, or classed inns based on NPC/inn "worth"

## Known issues ##

- ~~If NPCs in a town are moved, and the player moves far away from that town before they're moved back, then
  saves and reloads, those NPCs will probably stay moved.~~ should be fixed
- It's probably one big bowl of spaghetti
