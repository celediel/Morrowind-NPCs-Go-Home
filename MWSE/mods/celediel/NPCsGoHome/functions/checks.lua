-- handles logic checks for NPCs, doors, etc.
local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local dataTables = require("celediel.NPCsGoHome.functions.dataTables")
local cellEvaluators = require("celediel.NPCsGoHome.functions.cellEvaluators")

-- {{{ local functions
local function log(level, ...) if config.logLevel >= level then common.log(...) end end

-- patented by Merlord
local yeet = function(reference)
    tes3.positionCell({reference = reference, position = {0, 0, 10000}})
    reference:disable()
    timer.delayOneFrame(function() mwscript.setDelete({reference = reference}) end)
end

-- very todd workaround
local function getFightFromSpawnedReference(id)
    -- Spawn a reference of the given id in toddtest
    local toddTest = tes3.getCell({id = "toddtest"})
    log(common.logLevels.medium, "[CHECKS] Spawning %s in %s", id, toddTest.id)

    local ref = tes3.createReference({
        object = id,
        cell = toddTest,
        -- cell = tes3.getPlayerCell(),
        position = tes3vector3.new(0, 0, 0),
        -- position = {0, 0, 10000},
        orientation = tes3vector3.new(0, 0, 0)
    })

    local fight = ref.mobile.fight

    log(common.logLevels.medium, "[CHECKS] Got fight of %s, time to yeet %s", fight, id)

    yeet(ref)

    return fight
end
-- }}}

local this = {}

this.isInteriorCell = function(cell)
    if not cell then return end

    log(common.logLevels.large, "[CHECKS] Cell %s: interior: %s, behaves as exterior: %s therefore returning %s",
        cell.id, cell.isInterior, cell.behavesAsExterior, cell.isInterior and not cell.behavesAsExterior)

    return cell.isInterior and not cell.behavesAsExterior
end

this.isCityCell = function(internalCellId, externalCellId)
    -- easy mode
    if string.match(internalCellId, externalCellId) then
        log(common.logLevels.large, "[CHECKS] Easy mode city: %s in %s", internalCellId, externalCellId)
        return true
    end

    local cityMatch = "^(%w+), (.*)"
    -- check for "advanced" cities
    local _, _, internalCity = string.find(internalCellId, cityMatch)
    local _, _, externalCity = string.find(externalCellId, cityMatch)

    if externalCity and externalCity == internalCity then
        log(common.logLevels.large, "[CHECKS] Hard mode city: %s in %s, %s == %s", internalCellId, externalCellId,
            externalCity, internalCity)
        return true
    end

    log(common.logLevels.large, "[CHECKS] Hard mode not city: %s not in %s, %s ~= %s or both are nil", internalCellId,
        externalCellId, externalCity, internalCity)
    return false
end

this.isIgnoredCell = function(cell)
    log(common.logLevels.large, "[CHECKS] %s is %s", cell.id,
        config.ignored[cell.id:lower()] and "ignored" or "not ignored")

    return config.ignored[cell.id:lower()] -- or config.ignored[cell.sourceMod:lower()] -- or wilderness
end

this.fargothCheck = function()
    local fargothJournal = tes3.getJournalIndex({id = "MS_Lookout"})
    if not fargothJournal then return false end

    -- only disable Fargoth before speaking to Hrisskar, and after observing Fargoth sneak
    log(common.logLevels.large, "[CHECKS] Fargoth journal check %s: %s", fargothJournal,
        fargothJournal > 10 and fargothJournal <= 30)

    return fargothJournal > 10 and fargothJournal <= 30
end

this.offersTravel = function(npc)
    if not npc.object.aiConfig.travelDestinations then return false end

    for _ in tes3.iterate(npc.object.aiConfig.travelDestinations) do return true end

    return false
end

this.isIgnoredNPC = function(npc)
    local obj = npc.baseObject and npc.baseObject or npc.object

    -- ignore dead, attack on sight NPCs, and vampires
    local isDead = false
    local isHostile = false
    local isVampire = false
    local isWerewolf = false
    -- some TR "Hired Guards" aren't actually "guards", ignore them as well
    local isGuard = obj.isGuard or (obj.name and (obj.name:lower():match("guard") and true or false) or false) -- maybe this should just be an if else

    if npc.mobile then
        if npc.mobile.health.current <= 0 or npc.mobile.isDead then isDead = true end
        if npc.mobile.fight > 70 then isHostile = true end
        isVampire = tes3.isAffectedBy({reference = npc, effect = tes3.effect.vampirism})
        -- todo: non mwscript version of this
        isWerewolf = mwscript.getSpellEffects({reference = npc, spell = "werewolf vision"})
    else
        -- local fight = getFightFromSpawnedReference(obj.id) -- ! calling this hundreds of times is bad for performance lol
        -- if (fight or 0) > 70 then isHostile = true end
        isVampire = obj.head and (obj.head.vampiric and true or false) or false
        if obj.id:match("[Dd]ead") or obj.name:match("[Dd]ead") then isDead = true end
    end

    local isFargothActive = obj.id:match("fargoth") and this.fargothCheck() or false

    -- local isVampire = mwscript.getSpellEffects({reference = npc, spell = "vampire sun damage"})

    -- LuaFormatter off
    -- this just keeps getting uglier but it's debug logging so whatever I don't care
    log(common.logLevels.large, ("[CHECKS] Checking NPC:%s (%s or %s): id blocked:%s, %s blocked:%s " ..
        "guard:%s dead:%s vampire:%s werewolf:%s dreamer:%s follower:%s hostile:%s %s%s"),
        obj.name, npc.object.id, npc.object.baseObject and npc.object.baseObject.id or "nil",
        config.ignored[obj.id:lower()], obj.sourceMod, config.ignored[obj.sourceMod:lower()],
        isGuard, isDead, isVampire, isWerewolf, (obj.class and obj.class.id == "Dreamers"),
        common.runtimeData.followers[npc.object.id], isHostile, obj.id:match("fargoth") and "fargoth:" or "",
        obj.id:match("fargoth") and isFargothActive or "")

    return config.ignored[obj.id:lower()] or
           config.ignored[obj.sourceMod:lower()] or
           isGuard or
           isFargothActive or
           isDead or
           isHostile or
           common.runtimeData.followers[npc.object.id] or
           isVampire or
           isWerewolf or
           (obj.class and obj.class.id == "Dreamers")
    -- LuaFormatter on
end

this.isNPCPet = function(creature) -- > isPet, isLinkedToTravelNPC
    local obj = creature.baseObject and creature.baseObject or creature.object

    -- todo: more pets?
    -- pack guars
    if obj.id:match("guar") and obj.mesh:match("pack") then
        return true
        -- imperial carriages
    elseif obj.id:match("_[Hh]rs") and obj.mesh:match("_[Hh]orse") then
        return true, true
    else
        return false
    end
end

this.isSiltStrider = function(activator)
    local id = activator.object.id:lower()
    log(common.logLevels.large, "[PROC] Is %s a silt strider??", id)
    return id:match("siltstrider") or
           id:match("kil_silt")
end

-- checks NPC class and faction in cells for block list and adds to publicHouse list
-- todo: rewrite this
this.isPublicHouse = function(cell)
    -- only interior cells are public spaces
    if not this.isInteriorCell(cell) then return false end

    -- gather some data about the cell
    local city, publicHouseName

    if cell.name and string.match(cell.name, ",") then
        city = common.split(cell.name, ",")[1]
        publicHouseName = common.split(cell.name, ",")[2]:gsub("^%s", "")
    else
        city = "Wilderness"
        publicHouseName = cell.id
    end

    -- don't iterate NPCs in the cell if we've already marked it public
    if common.runtimeData.publicHouses.byName[city] and common.runtimeData.publicHouses.byName[city][cell.id] then
        return true
    end

    -- if it's a waistworks or plaza cell, it's public, with no proprietor
    if config.cantonCells == common.canton.public and common.isPublicCantonCell(cell) then
        dataTables.createPublicHouseTableEntry(cell, nil, city, publicHouseName,
                                               cellEvaluators.calculateCellWorth(cell),
                                               cellEvaluators.pickCellFaction(cell),
                                               common.publicHouseTypes.cantons)
        return true
    end

    local npcs = {factions = {}, total = 0}
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        -- Check for NPCS of ignored classes first
        if not this.isIgnoredNPC(npc) then
            if npc.object.class and config.ignored[npc.object.class.id:lower()] then
                log(common.logLevels.medium, "[CHECKS] NPC:\'%s\' of class:\'%s\' made %s public", npc.object.name,
                    npc.object.class and npc.object.class.id or "none", cell.name)

                dataTables.createPublicHouseTableEntry(cell, npc, city, publicHouseName,
                                                       cellEvaluators.calculateCellWorth(cell),
                                                       cellEvaluators.pickCellFaction(cell))
                return true
            end

            local faction = npc.object.faction

            if faction then
                local id = faction.id:lower()
                if not npcs.factions[id] then
                    npcs.factions[id] = {playerJoined = faction.playerJoined, total = 0, percentage = 0}
                end

                if not npcs.factions[id].master or npcs.factions[id].master.object.factionIndex <
                    npc.object.factionIndex then npcs.factions[id].master = npc end

                npcs.factions[id].total = npcs.factions[id].total + 1
            end

            npcs.total = npcs.total + 1
        end
    end

    -- Temples are always public
    if npcs.factions["temple"] and cell.name:lower():match("temple") then
        local master = npcs.factions["temple"].master
        log(common.logLevels.medium, "[CHECKS] %s is a temple, and %s, %s is the ranking member", cell.id,
            master.object.name, master.object.class)
        dataTables.createPublicHouseTableEntry(cell, master, city, publicHouseName,
                                               cellEvaluators.calculateCellWorth(cell),
                                               cellEvaluators.pickCellFaction(cell),
                                               common.publicHouseTypes.temples)
        return true
    end

    -- no NPCs of ignored classes, so let's check out factions
    for faction, info in pairs(npcs.factions) do
        info.percentage = (info.total / npcs.total) * 100
        log(common.logLevels.large,
            "[CHECKS] No NPCs of ignored class in %s, checking faction %s (ignored: %s, player joined: %s) with %s (%s%%) vs total %s",
            cell.name, faction, config.ignored[faction], info.playerJoined, info.total, info.percentage, npcs.total)

        -- less than configured amount of NPCs can't be a public house unless it's a Blades house
        if (config.ignored[faction] or info.playerJoined) and
            (npcs.total >= config.minimumOccupancy or faction == "Blades") and
            (info.percentage >= config.factionIgnorePercentage) then
            log(common.logLevels.medium, "[CHECKS] %s is %s%% faction %s, marking public.", cell.name, info.percentage, faction)

            -- try id based categorization, but fallback on guildhall
            local type = common.pickPublicHouseType(cell)
            if type == common.publicHouseTypes.inns then type = common.publicHouseTypes.guildhalls end

            dataTables.createPublicHouseTableEntry(cell, npcs.factions[faction].master, city, publicHouseName,
                                                   cellEvaluators.calculateCellWorth(cell),
                                                   cellEvaluators.pickCellFaction(cell),
                                                   common.publicHouseTypes.guildhalls)
            return true
        end
    end

    log(common.logLevels.large, "[CHECKS] %s isn't public", cell.name)
    return false
end

-- doors that lead to ignored, exterior, canton, unoccupied, or public cells, and doors that aren't in cities
this.isIgnoredDoor = function(door, homeCellId)
    -- don't lock prison markers
    if door.id == "PrisonMarker" then return true end

    -- don't lock non-cell change doors
    if not door.destination then
        log(common.logLevels.large, "[CHECKS] Non-Cell-change door %s, ignoring", door.id)
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
    local isCantonWorks = common.isCantonWorksCell(dest)

    -- LuaFormatter off
    log(common.logLevels.large, "[CHECKS] %s is %s, (%sin a city, is %spublic, %soccupied)",
        dest.id, this.isIgnoredCell(dest) and "ignored" or "not ignored",
        inCity and "" or "not ", leadsToPublicCell and "" or "not ", hasOccupants and "" or "un")

    return this.isIgnoredCell(dest) or
           not this.isInteriorCell(dest) or
           isCantonWorks or
           not inCity or
           leadsToPublicCell or
           not hasOccupants
end

this.isNight = function()
    local atNight = tes3.worldController.hour.value >= config.closeTime or -- AT NIGHT
                    tes3.worldController.hour.value <= config.openTime
    log(common.logLevels.large, "[CHECKS] Current time is %.2f (%snight), things are closed between %s and %s",
        tes3.worldController.hour.value, atNight and "" or "not ", config.closeTime, config.openTime)

    return atNight
    -- LuaFormatter on
end

-- inclement weather
this.isInclementWeather = function()
    if not tes3.getCurrentWeather() or this.isInteriorCell(tes3.getPlayerCell()) then return false end

    local index = tes3.getCurrentWeather().index
    local isBad = index >= config.worstWeather

    log(common.logLevels.large, "[CHECKS] Weather in %s: current:%s >= configured worst:%s, weather is %s",
        tes3.getRegion().id, index, config.worstWeather, isBad and "bad" or "great")

    return isBad
end

-- travel agents, their steeds, and argonians stick around
this.isBadWeatherNPC = function(npc)
    local is = this.offersTravel(npc) or config.badWeatherClassRace[npc.object.race.id] or
                   config.badWeatherClassRace[npc.object.class.id]
    log(common.logLevels.large, "[CHECKS] %s, %s%s is inclement weather NPC? %s", npc.object.name, npc.object.race.id,
        this.offersTravel(npc) and ", travel agent" or "", is)

    return is
end

return this

-- vim:set fdm=marker
