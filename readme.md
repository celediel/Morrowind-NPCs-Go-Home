# NPCs Go Home #

Forked from 1.1 of [OEA's Lightweight Lua Scheduling](https://www.nexusmods.com/morrowind/mods/48584) (I implemented most of the changes from 1.2 though)

## Things I've Added, Changed or Fixed ##

- timer for updating everything, configurable interval
- disabled NPCs are reenabled even if the option to disable NPCs is off
- Silt Striders and pack guars are disabled as well
- Inclement weather toggle removed, in favour of dropdown with "None" option
- Travel agents, their silt striders, and argonians configurably stay in inclement weather
- When locking doors, cells that contain NPCs of any class on the ignore list are left alone
  - cells that are >= 75% (configurable) one faction will be public, if that faction is on the ignore list
  - Additionally, NPCs in those cells can still be interacted with
- Cells with no NPCs are not locked
- Ignore list now supports NPC class and faction. Any interior cell with an NPC of
  ignored class or faction will not be locked, or have its NPCS disabled.
- NPC "homes"
  - Outside NPCs who have homes are currently paired with the inside cell of their home
  - Other NPCs are configurably paired with local public houses (Inns, temples, and guildhalls of their faction)

## WIP ##

- Option to move NPCs into their "home" rather than disable them
  - Kinda wonky? sometimes they die and I think it's because of placing numerous NPCs in the same spot
    - working on a better variety of positions in cells
- NPCs are classed based on the worth of their equipped items, and inventory
  - NPC worth is a table of: equipped items worth, inventory items worth, barter
    gold and if a merchant with a cell, the worth of items in containers in that
    cell that the NPC sells is added, and the total of all calculated values
- Public houses are classed based on the worth of NPCs in the cell
- Moved NPCs persist on save/load
  - works if the game is still running when the save is loaded
  - if the game is launched fresh, and a save with moved/disabled NPCs is loaded, it's still broken
    - ? WHY ?

## TODO ##

- move non-faction NPCs who don't have homes to temples or inns based on their "worth"
- pick temple for the poorest NPCs, or classed inns based on NPC/inn "worth"

## Known issues ##

- If NPCs in a town are moved, and the player moves far away from that town before they're moved back, then
  saves and reloads, those NPCs will probably stay moved.
- Launching the game and loading a save with moved/disabled NPCs, they won't be put back/enabled.
  - send help
