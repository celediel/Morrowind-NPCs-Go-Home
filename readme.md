# NPCs Go Home #
Forked from 1.1 of [OEA's Lightweight Lua Scheduling](https://www.nexusmods.com/morrowind/mods/48584) (I implemented most of the changes from 1.2 though)

## Things I've Added, Changed or Fixed ##

* timer for updating everything, configurable interval
* Silt Striders disappear as well
* Inclement weather toggle gone, in favour of dropdown with "None" option
* Travel agents, their silt striders, and argonians configurably stay in inclement weather
* When locking doors, cells that contain NPCs of any class on the block list are left alone
    * cells that are >= 75% one faction will be public, if that faction is on the block list
    * Additionally, NPCs in those cells are still interactive
* Block list now supports NPC class and faction. Any interior cell with an NPC of
blocked class or faction will not be locked, or have its NPCS disabled.
* NPC "homes"
    * Outside NPCs who have homes are currently paired with the inside cell of their home
    * Other NPCs are configurably paired with local public houses (Inns, Guildhalls and temples of their faction)

## WIP ##

* Option to move NPCs into their "home" rather than disable them
    * Kinda wonky? sometimes they die and I dunno why