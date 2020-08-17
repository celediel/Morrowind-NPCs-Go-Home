-- {{{ other files
-- ? could probably split this file out to others as well
local config = require("celediel.NPCsGoHome.config").getConfig()
local common = require("celediel.NPCsGoHome.common")
local interop = require("celediel.NPCsGoHome.interop")
local positions = require("celediel.NPCsGoHome.positions")
-- }}}

-- {{{ variables and such
-- Waistworks string match
-- I'm probably trying too hard to avoid false positives
local waistworks = {"^[Vv]ivec,?.*[Ww]aist", "[Cc]analworks", "[Ww]aistworks"}

-- timers
local updateTimer

-- NPC homes
local publicHouses = {}
local homes = {
    byName = {}, -- used to ensure duplicate homes are not created
    byCell = {} -- used for cellChange events
}

-- city name if cell.name is nil
local wilderness = "Wilderness"
-- maybe this shouldn't be hardcoded
local publicHouseTypes = {inns = "Inns", guildhalls = "Guildhalls", temples = "Temples", houses = "Houses"}
local movedNPCs = {}

-- build a list of followers on cellChange
local followers = {}

local zeroVector = tes3vector3.new(0, 0, 0)

-- animated morrowind NPCs are contextual
local contextualNPCs = {"^AM_"}

-- }}}

-- {{{ helper functions
local function log(level, ...) if config.logLevel >= level then common.log(...) end end
local function message(...) if config.showMessages then tes3.messageBox(...) end end

local function checkModdedCell(cellId)
    local id

    if cellId == "Balmora, South Wall Cornerclub" and tes3.isModActive("South Wall.ESP") then
        id = "Balmora, South Wall Den Of Iniquity"
    elseif cellId == "Balmora, Eight Plates" and tes3.isModActive("Eight Plates.esp") then
        id = "Balmora, Seedy Eight Plates"
    elseif cellId == "Hla Oad, Fatleg's Drop Off" and tes3.isModActive("Clean DR115_TheDropoff_HlaOadDocks.ESP") then
        id = "Hla Oad, The Drop Off"
    else
        id = cellId
    end

    return id
end

local function isInteriorCell(cell)
    if not cell then return end

    log(common.logLevels.large, "Cell %s: interior: %s, behaves as exterior: %s therefore returning %s",
        cell.id, cell.isInterior, cell.behavesAsExterior, cell.isInterior and not cell.behavesAsExterior)

    return cell.isInterior and not cell.behavesAsExterior
end

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
        orientation = zeroVector
    })

    local fight = ref.mobile.fight

    log(common.logLevels.medium, "Got fight of %s, time to yeet %s", fight, id)

    yeet(ref)

    return fight
end

-- {{{ npc evaluators

-- NPCs barter gold + value of all inventory items
local function calculateNPCWorth(npc, merchantCell)
    local worth = npc.object.barterGold
    local obj = npc.baseObject and npc.baseObject or npc.object

    if npc.object.inventory then
        for _, item in pairs(npc.object.inventory) do worth = worth + (item.object.value or 0) end
    end

    if merchantCell then -- if we pass a cell argument
        for box in merchantCell:iterateReferences(tes3.objectType.container) do -- loop over each container
            if box.inventory then -- if it's not empty
                for item in tes3.iterate(box.inventory) do -- loop over its items
                    if obj:tradesItemType(item.objectType) then -- if the NPC sells that type
                        worth = worth + item.object.value -- add its value to the NPCs total value
                    end
                end
            end
        end
    end

    return worth
end

-- }}}

-- {{{ housing

-- ? I honestly don't know if there are any wandering NPCs that "live" in close-by manors, but I wrote this anyway
local function checkManor(cellName, npcName)
    if not cellName or (cellName and not string.find(cellName, "Manor")) then return end

    local splitName = common.split(npcName)
    local given = splitName[1]
    local sur = splitName[2]

    -- surnameless peasants don't live in manors
    if not sur then return end

    log(common.logLevels.large, "Checking if %s %s lives in %s", given, sur, cellName)
    return string.match(cellName, sur)
end

local function pickPublicHouseType(cellName)
    if cellName:match("Guild") then
        return publicHouseTypes.guildhalls
    elseif cellName:match("Temple") then
        return publicHouseTypes.temples
    -- elseif cellName:match("House") then
    --     return publicHouseTypes.houses
    else
        return publicHouseTypes.inns
    end
end

local function pickInnForNPC(npc, city)
    -- todo: pick in Inn intelligently ?
    -- high class inns for nobles and rich merchants and such
    -- lower class inns for middle class npcs and merchants
    -- temple for commoners and the poorest people
    -- ? pick based on barterGold and value of equipment for merchants ?
    -- ? for others, pick based on value of equipment

    -- but for now pick one at random
    if publicHouses[city] and publicHouses[city][publicHouseTypes.inns] then
        local choice = table.choice(publicHouses[city][publicHouseTypes.inns])
        if not choice then return end
        log(common.logLevels.medium, "Picking inn %s, %s for %s", choice.city, choice.name, npc.object.name)
        return choice.cell
    end
end

local function pickPublicHouseForNPC(npc, city)
    -- look for wandering guild members
    if publicHouses[city] and publicHouses[city][publicHouseTypes.guildhalls] then
        for _, data in pairs(publicHouses[city][publicHouseTypes.guildhalls]) do
            -- if npc's faction and proprietor's faction match, pick that one
            if npc.object.faction == data.proprietor.object.faction then
                log(common.logLevels.medium, "Picking %s for %s based on faction", data.cell.id, npc.object.name)
                return data.cell
            end
        end
    end

    -- temple members go to the temple
    if publicHouses[city] and publicHouses[city][publicHouseTypes.temples] then
        for _, data in pairs(publicHouses[city][publicHouseTypes.temples]) do
            if npc.object.faction == data.proprietor.object.faction then
                log(common.logLevels.medium, "Picking temple %s for %s based on faction", data.cell.id, npc.object.name)
                return data.cell
            end
        end
    end

    -- found nothing so pick an inn
    return pickInnForNPC(npc, city)
end

local function createHomedNPCTableEntry(npc, home, startingPlace, isHome, position, orientation)
    if npc.object and (npc.object.name == nil or npc.object.name == "") then return end

    local pickedPosition, pickedOrientation, pos, ori

    -- mod support for different positions in cells
    local id = checkModdedCell(home.id)

    log(common.logLevels.medium, "Found %s for %s: %s... adding it to in memory table...",
        isHome and "home" or "public house", npc.object.name, id)

    if isHome and positions.npcs[npc.object.name] then
        pos = positions.npcs[npc.object.name].position
        ori = positions.npcs[npc.object.name].orientation
        -- pickedPosition = positions.npcs[npc.object.name] and tes3vector3.new(p[1], p[2], p[3]) or zeroVector:copy()
        -- pickedOrientation = positions.npcs[npc.object.name] and tes3vector3.new(o[1], o[2], o[3]) or zeroVector:copy()
    elseif positions.cells[id] then
        pos = table.choice(positions.cells[id]).position
        ori = table.choice(positions.cells[id]).orientation
        -- pickedPosition = positions.cells[id] and tes3vector3.new(p[1], p[2], p[3]) or zeroVector:copy()
        -- pickedOrientation = positions.cells[id] and tes3vector3.new(o[1], o[2], o[3]) or zeroVector:copy()
        -- pickedPosition = tes3vector3.new(p[1], p[2], p[3])
        -- pickedOrientation = tes3vector3.new(o[1], o[2], o[3])
    else
        pos = {0,0,0}
        ori = {0,0,0}
        -- pickedPosition = zeroVector:copy()
        -- pickedOrientation = zeroVector:copy()
    end

    pickedPosition = tes3vector3.new(pos[1], pos[2], pos[3])
    pickedOrientation = tes3vector3.new(ori[1], ori[2], ori[3])

    local ogPosition = position and
        (tes3vector3.new(position.x, position.y, position.z)) or
        (npc.position and npc.position:copy() or zeroVector:copy())

    local ogOrientation = orientation and
        (tes3vector3.new(orientation.x, orientation.y, orientation.z)) or
        (npc.orientation and npc.orientation:copy() or zeroVector:copy())

    local this = {
        name = npc.object.name,
        npc = npc, -- tes3npc
        isHome = isHome, -- bool
        home = home, -- tes3cell
        homeName = home.id,
        ogPlace = startingPlace, -- tes3cell
        ogPlaceName = startingPlace.id,
        ogPosition = ogPosition,
        ogOrientation = ogOrientation,
        homePosition = pickedPosition, -- tes3vector3
        homeOrientation = pickedOrientation, -- tes3vector3
        worth = calculateNPCWorth(npc) -- int
    }

    homes.byName[npc.object.name] = this
    if isHome then homes.byCell[home.id] = this end

    interop.setHomedNPCTable(homes.byName)

    return this
end

local function createPublicHouseTableEntry(publicCell, proprietor, city, name)
    local typeOfPub = pickPublicHouseType(publicCell.name)

    local worth = 0

    -- for houses, worth is equal to NPC who lives there
    -- if typeOfPub == publicHouseTypes.houses then
    --     worth = calculateNPCWorth(proprietor)
    -- else
        -- for other types, worth is combined worth of all NPCs
        for innard in publicCell:iterateReferences(tes3.objectType.npc) do
            if innard == proprietor then
                worth = worth + calculateNPCWorth(innard, publicCell)
            else
                worth = worth + calculateNPCWorth(innard)
            end
        end
    -- end

    if not publicHouses[city] then publicHouses[city] = {} end
    if not publicHouses[city][typeOfPub] then publicHouses[city][typeOfPub] = {} end

    publicHouses[city][typeOfPub][publicCell.id] = {
        name = name,
        city = city,
        cell = publicCell,
        proprietor = proprietor,
        proprietorName = proprietor.object.name,
        worth = worth
    }

    interop.setPublicHouseTable(publicHouses)
end

-- looks through doors to find a cell that matches a wandering NPCs name
local function pickHomeForNPC(cell, npc)
    -- wilderness cells don't have name
    if not cell.name then return end

    -- don't move contextual, such as Animated Morrowind, NPCs at all
    for _, str in pairs(contextualNPCs) do if npc.object.id:match(str) then return end end

    local name = npc.object.name
    local city = common.split(cell.name, ",")[1]
    for door in cell:iterateReferences(tes3.objectType.door) do
        if door.destination then
            local dest = door.destination.cell

            -- essentially, if npc full name, or surname matches the cell name
            if dest.id:match(name) or checkManor(dest.name, name) then
                if homes.byName[name] then -- already have a home, don't create the table entry again
                    return homes.byName[name]
                else
                    return createHomedNPCTableEntry(npc, dest, cell, true)
                end
            end
        end
    end

    -- haven't found a home, so put them in an inn or guildhall
    if config.homelessWanderersToPublicHouses then
        log(common.logLevels.medium, "Didn't find a home for %s, trying inns", npc.object.name)
        local dest = pickPublicHouseForNPC(npc, city)
        -- return createHomedNPCTableEntry(npc, dest, door)
        if dest then return createHomedNPCTableEntry(npc, dest, cell, false) end
    end

    return nil
end

-- }}}

-- {{{ checks

local function isCityCell(internalCellId, externalCellId)
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
        log(common.logLevels.large, "hard mode city: %s in %s, %s == %s",
            internalCellId, externalCellId, externalCity, internalCity)
        return true
    end

    log(common.logLevels.large, "hard mode not city: %s not in %s, %s ~= %s or both are nil",
        internalCellId, externalCellId, externalCity, internalCity)
    return false
end

local function isIgnoredCell(cell)
    log(common.logLevels.large, "%s is %s, %s is %s", cell.id, config.ignored[cell.id] and "ignored" or "not ignored",
        cell.sourceMod, config.ignored[cell.sourceMod] and "ignored" or "not ignored")

    -- don't do things in the wilderness
    -- local wilderness = false
    -- if not cell.name then wilderness = true end

    return config.ignored[cell.id] or config.ignored[cell.sourceMod] -- or wilderness
end

local function isCantonCell(cellName)
    for _, str in pairs(waistworks) do if cellName:match(str) then return true end end
    return false
end

local function fargothCheck()
    local fargothJournal = tes3.getJournalIndex({id = "MS_Lookout"})
    if not fargothJournal then return false end

    -- only disable Fargoth before speaking to Hrisskar, and after observing Fargoth sneak
    log(common.logLevels.large, "Fargoth journal check %s: %s", fargothJournal,
        fargothJournal > 10 and fargothJournal <= 30)

    return fargothJournal > 10 and fargothJournal <= 30
end

local function isIgnoredNPC(npc)
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
        isVampire = obj.head.vampiric and true or false -- don't set a reference ... is bool even a reference type??
    end

    local isFargothActive = obj.id:match("fargoth") and fargothCheck() or false

    -- todo: non mwscript version of this
    local isWerewolf = mwscript.getSpellEffects({reference = npc, spell = "werewolf vision"})
    -- local isVampire = mwscript.getSpellEffects({reference = npc, spell = "vampire sun damage"})

    -- this just keeps getting uglier but it's debug logging so whatever I don't care
    log(common.logLevels.large, ("Checking NPC:%s (%s or %s): id blocked:%s, %s blocked:%s " .. --
        "guard:%s dead:%s vampire:%s werewolf:%s dreamer:%s follower:%s hostile:%s %s%s"), --
        obj.name, npc.object.id, npc.object.baseObject and npc.object.baseObject.id or "nil", --
        config.ignored[string.lower(obj.id)], obj.sourceMod, config.ignored[string.lower(obj.sourceMod)], --
        obj.isGuard, isDead, isVampire, isWerewolf, (obj.class and obj.class.id == "Dreamers"), --
        followers[obj.id], isHostile, obj.id:match("fargoth") and "fargoth:" or "", obj.id:match("fargoth") and isFargothActive or "")

    return config.ignored[string.lower(obj.id)] or --
           config.ignored[string.lower(obj.sourceMod)] or --
           obj.isGuard or --
           isFargothActive or --
           isDead or -- don't move dead NPCS
           isHostile or --
           followers[obj.id] or -- ignore followers
           isVampire or --
           isWerewolf or --
           (obj.class and obj.class.id == "Dreamers") --
end

local function isNPCPet(creature)
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
local function isPublicHouse(cell)
    -- only interior cells are public "houses"
    if not isInteriorCell(cell) then return false end

    local typeOfPub = pickPublicHouseType(cell.name)
    local city, publicHouseName

    if cell.name and string.match(cell.name, ",") then
        city = common.split(cell.name, ",")[1]
        publicHouseName = common.split(cell.name, ",")[2]:gsub("^%s", "")
    else
        city = wilderness
        publicHouseName = cell.id
    end

    -- don't iterate NPCs in the cell if we've already marked it public
    if publicHouses[city] and (publicHouses[city][typeOfPub] and publicHouses[city][typeOfPub][cell.id]) then return true end

    local npcs = {factions = {}, total = 0}
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        -- Check for NPCS of ignored classes first
        if not isIgnoredNPC(npc) then
            if npc.object.class and config.ignored[npc.object.class.id] then
                log(common.logLevels.medium, "NPC:\'%s\' of class:\'%s\' made %s public", npc.object.name,
                    npc.object.class and npc.object.class.id or "none", cell.name)

                createPublicHouseTableEntry(cell, npc, city, publicHouseName)

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

            createPublicHouseTableEntry(cell, npcs.factions[faction].master, city, publicHouseName)
            return true
        end
    end

    log(common.logLevels.large, "%s isn't public", cell.name)
    return false
end

-- doors that lead to ignored, exterior, canton, unoccupied, or public cells, and doors that aren't in cities
local function isIgnoredDoor(door, homeCellId)
    -- don't lock non-cell change doors
    if not door.destination then
        log(common.logLevels.large, "Non-Cell-change door %s, ignoring", door.id)
        return true
    end

    -- Only doors in cities and towns (interior cells with names that contain the exterior cell)
    local inCity = isCityCell(door.destination.cell.id, homeCellId)

    -- peek inside doors to look for guild halls, inns and clubs
    local leadsToPublicCell = isPublicHouse(door.destination.cell)

    -- don't lock unoccupied cells
    local hasOccupants = false
    for npc in door.destination.cell:iterateReferences(tes3.objectType.npc) do
        if not isIgnoredNPC(npc) then
            hasOccupants = true
            break
        end
    end

    log(common.logLevels.large, "%s is %s, (%sin a city, is %spublic, %soccupied)", --
        door.destination.cell.id, isIgnoredCell(door.destination.cell) and "ignored" or "not ignored", -- destination is ignored
        inCity and "" or "not ", leadsToPublicCell and "" or "not ", hasOccupants and "" or "un") -- in a city, is public, is ocupado

    return isIgnoredCell(door.destination.cell) or
           not isInteriorCell(door.destination.cell) or
           isCantonCell(door.destination.cell.id) or
           not inCity or
           leadsToPublicCell or
           not hasOccupants
end

-- AT NIGHT
local function checkTime()
    log(common.logLevels.large, "Current time is %s, things are closed between %s and %s",
        tes3.worldController.hour.value, config.closeTime, config.openTime)
    return tes3.worldController.hour.value >= config.closeTime or tes3.worldController.hour.value <= config.openTime
end

-- inclement weather
local function checkWeather(cell)
    if not cell.region then return end

    log(common.logLevels.large, "Weather: %s >= %s == %s", cell.region.weather.index, config.worstWeather,
        cell.region.weather.index >= config.worstWeather)

    return cell.region.weather.index >= config.worstWeather
end

-- travel agents, their steeds, and argonians stick around
local function isBadWeatherNPC(npc)
    local obj = npc.baseObject and npc.baseObject or npc.object
    if not obj then return end

    log(common.logLevels.large, "NPC Inclement Weather: %s is %s, %s", npc.object.name, npc.object.class.name,
        npc.object.race.id)

    -- todo: better detection of NPCs who offer travel services
    -- found a rogue "shipmaster" in molag mar
    return obj.class.name == "Caravaner" or
           obj.class.name == "Gondolier" or
           obj.class.name == "Shipmaster" or
           obj.race.id == "Argonian"
end

-- }}}

-- {{{ cell change checks

local function checkEnteredNPCHome(cell)
    local home = homes.byCell[cell.id]
    if home then
        local msg = string.format("Entering home of %s, %s", home.name, home.homeName)
        log(common.logLevels.small, msg)
        -- message(msg) -- this one is mostly for debugging, so it doesn't need to be shown
    end
end

local function checkEnteredPublicHouse(cell, city)
    local typeOfPub = pickPublicHouseType(cell.name)

    local publicHouse = publicHouses[city] and (publicHouses[city][typeOfPub] and publicHouses[city][typeOfPub][cell.name])

    if publicHouse then
        local msg = string.format("Entering public space %s, a%s %s in the town of %s. Talk to %s, %s for services.",
                                  publicHouse.name, common.vowel(typeOfPub), typeOfPub:gsub("s$", ""), publicHouse.city,
                                  publicHouse.proprietor.object.name, publicHouse.proprietor.object.class)
        log(common.logLevels.small, msg)
        message(msg) -- this one is more informative, and not entirely for debugging, and reminiscent of Daggerfall's messages
    end
end

-- }}}

-- }}}

-- {{{ real meat and potatoes functions
local function moveNPC(homeData)
    -- add to in memory table
    table.insert(movedNPCs, homeData)
    interop.setMovedNPCTable(movedNPCs)

    -- set npc data, so we can move NPCs back after a load
    local npc = homeData.npc
    npc.data.NPCsGoHome = {
        position = {
            x = npc.position.x,
            y = npc.position.y,
            z = npc.position.z,
        },
        orientation = {
            x = npc.orientation.x,
            y = npc.orientation.y,
            z = npc.orientation.z,
        },
        cell = homeData.ogPlaceName
    }

    tes3.positionCell({
        cell = homeData.home,
        reference = homeData.npc,
        position = homeData.homePosition,
        orientation = homeData.homeOrientation
    })

    log(common.logLevels.medium, "Moving %s to home %s (%s, %s, %s)", homeData.npc.object.name, homeData.home.id,
        homeData.homePosition.x, homeData.homePosition.y, homeData.homePosition.z)
end

local function putNPCsBack()
    for i = #movedNPCs, 1, -1 do
        local data = table.remove(movedNPCs, i)
        log(common.logLevels.medium, "Moving %s back outside to %s (%s, %s, %s)", data.npc.object.name, data.ogPlace.id,
            data.ogPosition.x, data.ogPosition.y, data.ogPosition.z)

        -- unset NPC data so we don't try to move them on load
        data.npc.data.NPCsGoHome = nil

        -- and put them back
        tes3.positionCell({
            cell = data.ogPlace,
            reference = data.npc,
            position = data.ogPosition,
            orientation = data.ogPlace
        })
    end
    interop.setMovedNPCTable(movedNPCs)
end

-- search in a specific cell for moved NPCs
local function checkForMovedNPCs(cell)
    -- NPCs don't get moved to exterior cells, so no need to check them for moved NPCs
    if not isInteriorCell(cell) then return end

    log(common.logLevels.medium, "Looking for moved NPCs in cell %s", cell.id)
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        if npc.data and npc.data.NPCsGoHome then
            createHomedNPCTableEntry(npc, cell, tes3.getCell(npc.data.NPCsGoHome.cell), true, npc.data.NPCsGoHome.position, npc.data.NPCsGoHome.orientation)
        end
    end
end

local function searchCellsForNPCs()
    for _, cell in pairs(tes3.getActiveCells()) do
        -- check active cells
        checkForMovedNPCs(cell)
        for door in cell:iterateReferences(tes3.objectType.door) do
            if door.destination then
                -- then check cells attached to active cells
                checkForMovedNPCs(door.destination.cell)
            end
        end
    end
end

local function processNPCs(cell)
    -- todo: move this check somewhere else, so that disabled NPCs will be re-enabled even if the option is off
    if not config.disableNPCs then return end

    log(common.logLevels.small, "Looking for NPCs to process in cell:%s", cell.id)

    -- iterate NPCs in the cell, move them to their homes, and keep track of moved NPCs so we can move them back later
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        -- for npc, _ in pairs(cellsInMemory[cell].npcs) do
        if not isIgnoredNPC(npc) then
            log(common.logLevels.large, "People change")
            -- if not npc.data.NPCsGoHome then npc.data.NPCsGoHome = {} end

            -- find NPC homes
            local npcHome = config.moveNPCs and pickHomeForNPC(cell, npc) or nil

            local tmpLogLevelNPCHome = npcHome and common.logLevels.medium or common.logLevels.large
            log(tmpLogLevelNPCHome, "%s %s %s%s", npc.object.name,
                npcHome and (npcHome.isHome and "lives in" or "goes to") or "lives",
                npcHome and npcHome.home or "nowhere", npcHome and (npcHome.isHome and "." or " at night.") or ".")

            -- disable or move NPCs
            if (checkTime() or
                (checkWeather(cell) and
                    (not isBadWeatherNPC(npc) or (isBadWeatherNPC(npc) and not config.keepBadWeatherNPCs)))) then
                if npcHome then
                    moveNPC(npcHome)
                -- elseif not npc.data.NPCsGoHome.modified then
                elseif not npc.disabled then
                    log(common.logLevels.medium, "Disabling homeless %s", npc.object.name)
                    -- npc:disable() -- ! this one sometimes causes crashes
                    mwscript.disable({reference = npc}) -- ! this one is deprecated
                    -- tes3.setEnabled({reference = npc, enabled = false}) -- ! but this one causes crashes too
                    -- npc.data.NPCsGoHome.modified = true
                else
                    log(common.logLevels.medium, "Didn't do anything with %s", npc.object.name)
                end
            else
                -- if not npcHome and npc.data.modified then
                if not npcHome and npc.disabled then
                    log(common.logLevels.medium, "Enabling homeless %s", npc.object.name)
                    -- npc:enable()
                    mwscript.enable({reference = npc})
                    -- tes3.setEnabled({reference = npc, enabled = true})
                    -- npc.data.NPCsGoHome.modified = false
                end
            end
        end
    end

    -- now put NPCs back
    -- if not (checkTime() or checkWeather(cell)) and #movedNPCs > 0 then putNPCsBack() end
    if not (checkTime() or checkWeather(cell)) then putNPCsBack() end
end

local function processSiltStriders(cell)
    if not config.disableNPCs then return end

    log(common.logLevels.small, "Looking for silt striders to process in cell:%s", cell.name)
    for activator in cell:iterateReferences(tes3.objectType.activator) do
        log(common.logLevels.large, "Is %s a silt strider??", activator.object.id)
        if activator.object.id:match("siltstrider") then
            if checkTime() or (checkWeather(cell) and not config.keepBadWeatherNPCs) then
                if not activator.disabled then
                    log(common.logLevels.medium, "Disabling silt strider %s!", activator.object.name)
                    mwscript.disable({reference = activator})
                    -- activator:disable()
                    -- tes3.setEnabled({reference = activator, enabled = false})
                end
            else
                if activator.disabled then
                    log(common.logLevels.medium, "Enabling silt strider %s!", activator.object.name)
                    mwscript.enable({reference = activator})
                    -- activator:enable()
                    -- tes3.setEnabled({reference = activator, enabled = true})
                end
            end
        end
    end
    log(common.logLevels.large, "Done with silt striders")
end

-- deal with trader's guars, and other npc linked creatures/whatever
local function processPets(cell)
    if not config.disableNPCs then return end

    log(common.logLevels.small, "Looking for NPC pets to process in cell:%s", cell.name)

    for creature in cell:iterateReferences(tes3.objectType.creature) do
        if isNPCPet(creature) then
            if checkTime() then
                -- disable
                if not creature.disabled then
                    log(common.logLevels.medium, "Disabling NPC Pet %s!", creature.object.id)
                    mwscript.disable({reference = creature })
                end
            else
                -- enable
                if creature.disabled then
                    log(common.logLevels.medium, "Enabling NPC Pet %s!", creature.object.id)
                    mwscript.enable({reference = creature })
                end
            end
        end
    end
end

local function processDoors(cell)
    if not config.lockDoors then return end

    log(common.logLevels.small, "Looking for doors to process in cell:%s", cell.id)

    for door in cell:iterateReferences(tes3.objectType.door) do
        if not door.data.NPCsGoHome then door.data.NPCsGoHome = {} end

        if not isIgnoredDoor(door, cell.id) then
            -- don't mess around with doors that are already locked
            if door.data.NPCsGoHome.alreadyLocked == nil then
                door.data.NPCsGoHome.alreadyLocked = tes3.getLocked({reference = door})
            end

            log(common.logLevels.large, "Found %slocked %s with destination %s",
                door.data.NPCsGoHome.alreadyLocked and "" or "un", door.id, door.destination.cell.id)

            if checkTime() then
                if not door.data.NPCsGoHome.alreadyLocked then
                    log(common.logLevels.medium, "locking: %s to %s", door.object.name, door.destination.cell.id)

                    local lockLevel = math.random(25, 100)
                    tes3.lock({reference = door, level = lockLevel})
                    door.data.NPCsGoHome.modified = true
                end
            else
                -- only unlock doors that we locked before
                if door.data.NPCsGoHome.modified then
                    door.data.NPCsGoHome.modified = false

                    tes3.setLockLevel({reference = door, level = 0})
                    tes3.unlock({reference = door})

                    log(common.logLevels.medium, "unlocking: %s to %s", door.object.name, door.destination.cell.id)
                end
            end

            log(common.logLevels.large, "Now locked Status: %s", tes3.getLocked({reference = door}))
        end
    end
    log(common.logLevels.large, "Done with doors")
end

local function applyChanges(cell)
    if not cell then cell = tes3.getPlayerCell() end

    -- build our followers list
    for friend in tes3.iterate(tes3.mobilePlayer.friendlyActors) do
        local obj = friend.baseObject and friend.baseObject or friend.object

        if friend ~= tes3.mobilePlayer then
            followers[obj.id] = true
            -- log(common.logLevels.large, "%s is follower", obj.id)
        end
    end

    if isIgnoredCell(cell) then return end

    -- Interior cell, except Waistworks, don't do anything
    if isInteriorCell(cell) and not (config.waistWorks and isCantonCell(cell.id)) then return end

    -- don't do anything to public houses
    if isPublicHouse(cell) then return end

    -- Deal with NPCs and mounts in cell
    processNPCs(cell)
    processPets(cell)
    processSiltStriders(cell)

    -- check doors in cell, locking those that aren't inns/clubs
    processDoors(cell)
end

local function updateCells()
    log(common.logLevels.medium, "Updating active cells!")

    for _, cell in pairs(tes3.getActiveCells()) do
        log(common.logLevels.large, "Applying changes to cell %s", cell.id)
        applyChanges(cell)
    end
end

local function updatePlayerTrespass(cell, previousCell)
    cell = cell or tes3.getPlayerCell()

    local inCity = previousCell and (previousCell.id:match(cell.id) or cell.id:match(previousCell.id))

    if isInteriorCell(cell) and not isIgnoredCell(cell) and not isPublicHouse(cell) and inCity then
        if checkTime() then
            tes3.player.data.NPCsGoHome.intruding = true
        else
            tes3.player.data.NPCsGoHome.intruding = false
        end
    else
        tes3.player.data.NPCsGoHome.intruding = false
    end
    log(common.logLevels.small, "Updating player trespass status to %s", tes3.player.data.NPCsGoHome.intruding)
end

-- }}}

-- {{{ event functions
local function onActivated(e)
    if e.activator ~= tes3.player or e.target.object.objectType ~= tes3.objectType.npc or not config.disableInteraction then
        return
    end

    if tes3.player.data.NPCsGoHome.intruding and not isIgnoredNPC(e.target) then
        tes3.messageBox(string.format("%s: Get out before I call the guards!", e.target.object.name))
        return false
    end
end

local function onLoaded()
    tes3.player.data.NPCsGoHome = tes3.player.data.NPCsGoHome or {}
    -- tes3.player.data.NPCsGoHome.movedNPCs = tes3.player.data.NPCsGoHome.movedNPCs or {}
    -- movedNPCs = tes3.player.data.NPCsGoHome.movedNPCs or {}
    if tes3.player.cell then searchCellsForNPCs() end

    if not updateTimer or (updateTimer and updateTimer.state ~= timer.active) then
        updateTimer = timer.start({
            type = timer.simulate,
            duration = config.timerInterval,
            iterations = -1,
            callback = updateCells
        })
    end
end

local function onCellChanged(e)
    updateCells()
    updatePlayerTrespass(e.cell, e.previousCell)
    checkEnteredNPCHome(e.cell)
    if e.cell.name then -- exterior wilderness cells don't have name
        checkEnteredPublicHouse(e.cell, common.split(e.cell.name, ",")[1])
    end
end
-- }}}

-- {{{ event registering
event.register("loaded", onLoaded)
event.register("cellChanged", onCellChanged)

event.register("activate", onActivated)

event.register("modConfigReady", function() mwse.mcm.register(require("celediel.NPCsGoHome.mcm")) end)
-- }}}

-- vim:fdm=marker
