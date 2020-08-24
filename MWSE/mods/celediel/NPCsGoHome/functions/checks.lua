-- handles logic checks for NPCs, doors, etc.
local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local dataTables = require("celediel.NPCsGoHome.functions.dataTables")

-- {{{ local variables and such
-- Canton string matches
-- move NPCs into waistworks
local waistworks = "[Ww]aistworks"
-- don't lock canalworks
local canalworks = "[Cc]analworks"
-- doors to underworks should be ignored
-- but NPCs in underworks should not be disabled
local underworks = "[Uu]nderworks"

-- city name if cell.name is nil
local wilderness = "Wilderness"
-- }}}

-- {{{ local functions
local function log(level, ...) if config.logLevel >= level then common.log(...) end end

-- patented by Merlord
local yeet = function(reference)
    -- tes3.positionCell({reference = reference, position = {0, 0, 10000}})
    reference:disable()
    timer.delayOneFrame(function() mwscript.setDelete({reference = reference}) end)
end

-- very todd workaround
local function getFightFromSpawnedReference(id)
    -- Spawn a reference of the given id in toddtest
    local toddTest = tes3.getCell("toddtest")
    log(common.logLevels.medium, "Spawning %s in %s", id, toddTest.id)

    local ref = tes3.createReference({
        object = id,
        -- cell = toddTest,
        cell = tes3.getPlayerCell(),
        -- position = zeroVector,
        position = {0, 0, 10000},
        orientation = tes3vector3.new(0, 0, 0)
    })

    local fight = ref.mobile.fight

    log(common.logLevels.medium, "Got fight of %s, time to yeet %s", fight, id)

    yeet(ref)

    return fight
end
-- }}}

local this = {}

this.isInteriorCell = function(cell)
    if not cell then return end

    log(common.logLevels.large, "Cell %s: interior: %s, behaves as exterior: %s therefore returning %s", cell.id,
        cell.isInterior, cell.behavesAsExterior, cell.isInterior and not cell.behavesAsExterior)

    return cell.isInterior and not cell.behavesAsExterior
end

this.isCityCell = function(internalCellId, externalCellId)
    -- easy mode
    if string.match(internalCellId, externalCellId) then
        log(common.logLevels.large, "easy mode city: %s in %s", internalCellId, externalCellId)
        return true
    end

    local cityMatch = "^(%w+), (.*)"
    -- check for "advanced" cities
    local _, _, internalCity = string.find(internalCellId, cityMatch)
    local _, _, externalCity = string.find(externalCellId, cityMatch)

    if externalCity and externalCity == internalCity then
        log(common.logLevels.large, "hard mode city: %s in %s, %s == %s", internalCellId, externalCellId, externalCity,
            internalCity)
        return true
    end

    log(common.logLevels.large, "hard mode not city: %s not in %s, %s ~= %s or both are nil", internalCellId,
        externalCellId, externalCity, internalCity)
    return false
end

this.isIgnoredCell = function(cell)
    log(common.logLevels.large, "%s is %s, %s is %s", cell.id, config.ignored[cell.id] and "ignored" or "not ignored",
        cell.sourceMod, config.ignored[cell.sourceMod] and "ignored" or "not ignored")

    -- don't do things in the wilderness
    -- local wilderness = false
    -- if not cell.name then wilderness = true end

    return config.ignored[cell.id] or config.ignored[cell.sourceMod] -- or wilderness
end

this.isCantonWorksCell = function(cell)
    -- for _, str in pairs(waistworks) do if cell.id:match(str) then return true end end
    return cell.id:match(waistworks) or cell.id:match(canalworks) or cell.id:match(underworks)
end

this.isCantonCell = function(cell)
    if this.isInteriorCell(cell) then return false end
    for door in cell:iterateReferences(tes3.objectType.door) do
        if door.destination and this.isCantonWorksCell(door.destination.cell) then return true end
    end
    return false
end

-- ! this one depends on tes3 ! --
this.fargothCheck = function()
    local fargothJournal = tes3.getJournalIndex({id = "MS_Lookout"})
    if not fargothJournal then return false end

    -- only disable Fargoth before speaking to Hrisskar, and after observing Fargoth sneak
    log(common.logLevels.large, "Fargoth journal check %s: %s", fargothJournal,
        fargothJournal > 10 and fargothJournal <= 30)

    return fargothJournal > 10 and fargothJournal <= 30
end

this.isIgnoredNPC = function(npc)
    local obj = npc.baseObject and npc.baseObject or npc.object

    -- ignore dead, attack on sight NPCs, and vampires
    local isDead = false
    local isHostile = false
    local isVampire = false

    if npc.mobile then
        if npc.mobile.health.current <= 0 or npc.mobile.isDead then isDead = true end
        if npc.mobile.fight > 70 then isHostile = true end
        isVampire = tes3.isAffectedBy({reference = npc, effect = tes3.effect.vampirism})
    else
        -- local fight = getFightFromSpawnedReference(obj.id) -- ! calling this hundreds of times is bad for performance lol
        -- if (fight or 0) > 70 then isHostile = true end
        isVampire = obj.head and (obj.head.vampiric and true or false) or false
        if obj.id:match("[Dd]ead") or obj.name:match("[Dd]ead") then isDead = true end
    end

    local isFargothActive = obj.id:match("fargoth") and this.fargothCheck() or false

    -- todo: non mwscript version of this
    local isWerewolf = mwscript.getSpellEffects({reference = npc, spell = "werewolf vision"})
    -- local isVampire = mwscript.getSpellEffects({reference = npc, spell = "vampire sun damage"})

    -- this just keeps getting uglier but it's debug logging so whatever I don't care
    log(common.logLevels.large, ("Checking NPC:%s (%s or %s): id blocked:%s, %s blocked:%s " .. --
        "guard:%s dead:%s vampire:%s werewolf:%s dreamer:%s follower:%s hostile:%s %s%s"), --
        obj.name, npc.object.id, npc.object.baseObject and npc.object.baseObject.id or "nil", --
        config.ignored[obj.id:lower()], obj.sourceMod, config.ignored[obj.sourceMod:lower()], --
        obj.isGuard, isDead, isVampire, isWerewolf, (obj.class and obj.class.id == "Dreamers"), --
        common.runtimeData.followers[npc.object.id], isHostile, obj.id:match("fargoth") and "fargoth:" or "", --
        obj.id:match("fargoth") and isFargothActive or "")

    return config.ignored[obj.id:lower()] or --
           config.ignored[obj.sourceMod:lower()] or --
           obj.isGuard or --
           isFargothActive or --
           isDead or -- don't move dead NPCS
           isHostile or --
           common.runtimeData.followers[npc.object.id] or -- ignore followers
           isVampire or --
           isWerewolf or --
           (obj.class and obj.class.id == "Dreamers") --
end

this.isNPCPet = function(creature)
    local obj = creature.baseObject and creature.baseObject or creature.object

    -- todo: more pets?
    if obj.id:match("guar") and obj.mesh:match("pack") then
        return true
    else
        return false
    end
end

-- checks NPC class and faction in cells for block list and adds to publicHouse list
-- todo: rewrite this
this.isPublicHouse = function(cell)
    -- only interior cells are public spaces
    if not this.isInteriorCell(cell) then return false end

    -- gather some data about the cell
    local typeOfPub = common.pickPublicHouseType(cell)
    local city, publicHouseName

    if cell.name and string.match(cell.name, ",") then
        city = common.split(cell.name, ",")[1]
        publicHouseName = common.split(cell.name, ",")[2]:gsub("^%s", "")
    else
        city = wilderness
        publicHouseName = cell.id
    end

    -- don't iterate NPCs in the cell if we've already marked it public
    if common.runtimeData.publicHouses[city] and
        (common.runtimeData.publicHouses[city][typeOfPub] and common.runtimeData.publicHouses[city][typeOfPub][cell.id]) then
        return true
    end

    -- if it's a waistworks cell, it's public, with no proprietor
    if config.waistWorks == common.waist.public and cell.id:match(waistworks) then
        dataTables.createPublicHouseTableEntry(cell, nil, city, publicHouseName)
        return true
    end

    local npcs = {factions = {}, total = 0}
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        -- Check for NPCS of ignored classes first
        if not this.isIgnoredNPC(npc) then
            if npc.object.class and config.ignored[npc.object.class.id] then
                log(common.logLevels.medium, "NPC:\'%s\' of class:\'%s\' made %s public", npc.object.name,
                    npc.object.class and npc.object.class.id or "none", cell.name)

                dataTables.createPublicHouseTableEntry(cell, npc, city, publicHouseName)

                return true
            end

            local faction = npc.object.faction

            if faction then
                if not npcs.factions[faction] then npcs.factions[faction] = {total = 0, percentage = 0} end

                if not npcs.factions[faction].master or npcs.factions[faction].master.object.factionIndex <
                    npc.object.factionIndex then npcs.factions[faction].master = npc end

                npcs.factions[faction].total = npcs.factions[faction].total + 1
            end

            npcs.total = npcs.total + 1
        end
    end

    -- no NPCs of ignored classes, so let's check out factions
    for faction, info in pairs(npcs.factions) do
        info.percentage = (info.total / npcs.total) * 100
        log(common.logLevels.large,
            "No NPCs of ignored class in %s, checking faction %s (ignored: %s, player joined: %s) with %s (%s%%) vs total %s",
            cell.name, faction, config.ignored[faction.id], faction.playerJoined, info.total, info.percentage,
            npcs.total)

        -- less than 3 NPCs can't possibly be a public house unless it's a Blades house
        if (config.ignored[faction.id] or faction.playerJoined) and
            (npcs.total >= config.minimumOccupancy or faction == "Blades") and info.percentage >=
            config.factionIgnorePercentage then
            log(common.logLevels.medium, "%s is %s%% faction %s, marking public.", cell.name, info.percentage, faction)

            dataTables.createPublicHouseTableEntry(cell, npcs.factions[faction].master, city, publicHouseName)
            return true
        end
    end

    log(common.logLevels.large, "%s isn't public", cell.name)
    return false
end

-- doors that lead to ignored, exterior, canton, unoccupied, or public cells, and doors that aren't in cities
this.isIgnoredDoor = function(door, homeCellId)
    -- don't lock non-cell change doors
    if not door.destination then
        log(common.logLevels.large, "Non-Cell-change door %s, ignoring", door.id)
        return true
    end

    -- we use this a lot, so set a reference to it
    local dest = door.destination.cell

    -- Only doors in cities and towns (interior cells with names that contain the exterior cell)
    local inCity = this.isCityCell(dest.id, homeCellId)

    -- peek inside doors to look for guild halls, inns and clubs
    local leadsToPublicCell = this.isPublicHouse(dest)

    -- don't lock unoccupied cells
    local hasOccupants = false
    for npc in dest:iterateReferences(tes3.objectType.npc) do
        if not this.isIgnoredNPC(npc) then
            hasOccupants = true
            break
        end
    end

    -- don't lock doors to canton cells
    local isCantonWorks = this.isCantonWorksCell(dest)

    log(common.logLevels.large, "%s is %s, (%sin a city, is %spublic, %soccupied)", --
    dest.id, this.isIgnoredCell(dest) and "ignored" or "not ignored", -- destination is ignored
    inCity and "" or "not ", leadsToPublicCell and "" or "not ", hasOccupants and "" or "un") -- in a city, is public, is ocupado

    return
        this.isIgnoredCell(dest) or not this.isInteriorCell(dest) or isCantonWorks or not inCity or leadsToPublicCell or
            not hasOccupants
end

-- AT NIGHT
this.checkTime = function()
    log(common.logLevels.large, "Current time is %s, things are closed between %s and %s",
        tes3.worldController.hour.value, config.closeTime, config.openTime)
    return tes3.worldController.hour.value >= config.closeTime or tes3.worldController.hour.value <= config.openTime
end

-- inclement weather
this.checkWeather = function(cell)
    if not cell.region then return end

    log(common.logLevels.large, "Weather: %s >= %s == %s", cell.region.weather.index, config.worstWeather,
        cell.region.weather.index >= config.worstWeather)

    return cell.region.weather.index >= config.worstWeather
end

-- travel agents, their steeds, and argonians stick around
this.isBadWeatherNPC = function(npc)
    local obj = npc.baseObject and npc.baseObject or npc.object
    if not obj then return end

    log(common.logLevels.large, "NPC Inclement Weather: %s is %s, %s", npc.object.name, npc.object.class.name,
        npc.object.race.id)

    -- todo: better detection of NPCs who offer travel services
    -- found a rogue "shipmaster" in molag mar
    return obj.class.name == "Caravaner" or obj.class.name == "Gondolier" or obj.class.name == "Shipmaster" or
               obj.race.id == "Argonian"
end

return this
