# NPCs Go Home #
Forked from 1.1 of [OEA's Lightweight Lua Scheduling](https://www.nexusmods.com/morrowind/mods/48584) (I implemented most of the changes from 1.2 though)

## Things I've Added, Changed or Fixed ##

* timer for updating everything, configurable interval
* Silt Striders disappear as well
* Inclement weather toggle removed, in favour of dropdown with "None" option
* Travel agents, their silt striders, and argonians configurably stay in inclement weather
* When locking doors, cells that contain NPCs of any class on the ignore list are left alone
    * cells that are >= 75% (configurable) one faction will be public, if that faction is on the ignore list
    * Additionally, NPCs in those cells can still be interacted with
* Cells with no NPCs are not locked
* Ignore list now supports NPC class and faction. Any interior cell with an NPC of
ignored class or faction will not be locked, or have its NPCS disabled.
* NPC "homes"
    * Outside NPCs who have homes are currently paired with the inside cell of their home
    * Other NPCs are configurably paired with local public houses (Inns, temples, and guildhalls of their faction)

## WIP ##

* Option to move NPCs into their "home" rather than disable them
    * Kinda wonky? sometimes they die and I think it's because of placing numerous NPCs in the same spot
        * working on a better variety of positions in cells
* NPCs are classed based on the worth of their equipped items, and inventory
* Public houses are classed based on the worth of NPCs in the cell