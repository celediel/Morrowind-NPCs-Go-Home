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
local homedNPCS = {}
local publicHouses = {}
-- city name if cell.name is nil
local wilderness = "Wilderness"
-- maybe this shouldn't be hardcoded
local publicHouseTypes = {inns = "Inns", guildhalls = "Guildhalls", temples = "Temples", houses = "Houses"}
-- local movedNPCs = {}

-- build a list of followers on cellChange
local followers = {}

local zeroVector = tes3vector3.new(0, 0, 0)

-- animated morrowind NPCs are contextual
local contextualNPCs = {"^AM_"}

-- }}}

-- {{{ helper functions
local function log(level, ...) if config.logLevel >= level then common.log(...) end end

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

-- {{{ npc evaluators

-- NPCs barter gold + value of all inventory items
local function calculateNPCWorth(npc)
    local worth = npc.object.barterGold

    if npc.object.inventory then
        for _, item in pairs(npc.object.inventory) do worth = worth + (item.object.value or 0) end
    end

    return worth
end

-- }}}

-- {{{ housing

-- ? I honestly don't know if there are any wandering NPCs that "live" in close-by manors, but I wrote this anyway
local function checkIfManor(cellName, npcName)
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
    elseif cellName:match("House") then
        return publicHouseTypes.houses
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

local function createHomedNPCTableEntry(npc, home, startingPlace, isHome)
    if npc.object and (npc.object.name == nil or npc.object.name == "") then return end
    log(common.logLevels.medium, "Found home for %s: %s... adding it to in memory table...", npc.object.name, home.id)

    local pickedPosition, pickedOrientation, p, o

    -- mod support for different positions in cells
    local id = checkModdedCell(home.id)

    if isHome and positions.npcs[npc.object.name] then
        p = positions.npcs[npc.object.name].position
        o = positions.npcs[npc.object.name].orientation
        pickedPosition = positions.npcs[npc.object.name] and tes3vector3.new(p[1], p[2], p[3]) or zeroVector:copy()
        pickedOrientation = positions.npcs[npc.object.name] and tes3vector3.new(o[1], o[2], o[3]) or zeroVector:copy()
    elseif positions.cells[id] then
        p = table.choice(positions.cells[id]).position
        o = table.choice(positions.cells[id]).orientation
        pickedPosition = positions.cells[id] and tes3vector3.new(p[1], p[2], p[3]) or zeroVector:copy()
        pickedOrientation = positions.cells[id] and tes3vector3.new(o[1], o[2], o[3]) or zeroVector:copy()
    else
        pickedPosition = zeroVector:copy()
        pickedOrientation = zeroVector:copy()
    end

    local this = {
        name = npc.object.name,
        npc = npc,
        isHome = isHome,
        home = home,
        homeName = home.id,
        ogPlace = startingPlace,
        ogPlaceName = startingPlace.id,
        ogPosition = npc.position and npc.position:copy() or zeroVector:copy(),
        ogOrientation = npc.orientation and npc.orientation:copy() or zeroVector:copy(),
        homePosition = pickedPosition,
        homeOrientation = pickedOrientation,
        worth = calculateNPCWorth(npc)
    }

    homedNPCS[home.id] = this

    interop.setHomedNPCTable(homedNPCS)

    return this
end

local function createPublicHouseTableEntry(publicCell, proprietor)
    local city, publicHouseName

    if publicCell.name and string.match(publicCell.name, ",") then
        city = common.split(publicCell.name, ",")[1]
        publicHouseName = common.split(publicCell.name, ",")[2]:gsub("^%s", "")
    else
        city = wilderness
        publicHouseName = publicCell.id
    end
    local type = pickPublicHouseType(publicCell.name)

    local worth = 0

    -- for houses, worth is equal to NPC who lives there
    if type ==  publicHouseTypes.houses then
        worth = calculateNPCWorth(proprietor)
    else
        -- for other types, worth is combined worth of all NPCs
        for innard in publicCell:iterateReferences(tes3.objectType.npc) do
            worth = worth + calculateNPCWorth(innard)
        end
    end

    if not publicHouses[city] then publicHouses[city] = {} end
    if not publicHouses[city][type] then publicHouses[city][type] = {} end

    publicHouses[city][type][publicCell.name] = {
        name = publicHouseName,
        city = city,
        cell = publicCell,
        proprietor = proprietor,
        proprietorName = proprietor.object.name,
        worth = worth
    }

    interop.setInnTable(publicHouses)
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
            if dest.id:match(name) or checkIfManor(dest.name, name) then
                return createHomedNPCTableEntry(npc, dest, cell, true)
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

local function fargothCheck()
    --[[
        ID:	MS_Lookout
        index   Finishes    Entry
        10                  Hrisskar Flat-Foot asked me to do him a favor. He believes that
                            Fargoth has been hiding money from the Imperials, and he'd like to
                            know where it's gone. If I will work for him, he will give me a share
                            of the bounty.
        20                  I've agreed to help Hrisskar find the money that Fargoth has been
                            hiding away. I am supposed to keep an eye on him from atop the
                            lighthouse in town, and watch where he goes. Hrisskar believes I
                            should watch him at night. I'm not supposed to approach him at any
                            time. I should then retrace his footsteps and find out where he's
                            hidden the money. When I've found it, I should report back to
                            Hrisskar.
        30	    ☑	        I've decided not to help Hrisskar.
        40                  I've found Fargoth's hidden stash. He keeps it in a hollow
                            treestump in a muck pond in town.
        100	    ☑	        Hrisskar was grateful that I found the money that Fargoth had been
                            hiding. He rewarded me with some gold, and told me I could keep
                            anything else I found in the bag besides the money he wanted.
    ]]
    local fargothJournal = tes3.getJournalIndex({ id = "MS_Lookout" })
    if not fargothJournal then return false end

    -- only disable Fargoth before speaking to Hrisskar, and after observing Fargoth sneak
    log(common.logLevels.large, "Fargoth journal check %s: %s", fargothJournal, fargothJournal > 10 and fargothJournal <= 30)
    return fargothJournal > 10 and fargothJournal <= 30
end

local function isIgnoredNPC(npc)
    local obj = npc.object.baseObject and npc.object.baseObject or npc.object

    -- ignore dead, attack on sight NPCs, and vampires
    local isDead = false
    local isHostile = false
    local isVampire = false
    if npc.mobile then
        if npc.mobile.health.current <= 0 then isDead = true end
        if npc.mobile.fight > 70 then isHostile = true end
        isVampire = tes3.isAffectedBy({reference = npc, effect = tes3.effect.vampirism})
    end

    local isFargothActive = obj.id == "fargoth" and fargothCheck() or false

    -- todo: non mwscript version of this
    local isWerewolf = mwscript.getSpellEffects({reference = npc, spell = "werewolf vision"})
    -- local isVampire = mwscript.getSpellEffects({reference = npc, spell = "vampire sun damage"})

    -- this just keeps getting uglier but it's debug logging so whatever I don't care
    log(common.logLevels.large, ("Checking NPC:%s (%s or %s): id blocked:%s, mod blocked:%s " ..
        "guard:%s dead:%s vampire:%s werewolf:%s dreamer:%s follower:%s hostile:%s %s%s"),
        obj.name, npc.object.id, npc.object.baseObject and npc.object.baseObject.id or "nil",
        config.ignored[obj.id], config.ignored[obj.sourceMod], obj.isGuard, isDead, isVampire,
        isWerewolf, (obj.class and obj.class.id == "Dreamers"), followers[obj.id], isHostile,
        obj.id == "fargoth" and "fargoth:" or "", obj.id == "fargoth" and isFargothActive or "")

    return config.ignored[obj.id] or --
           config.ignored[obj.sourceMod] or --
           obj.isGuard or --
           isFargothActive or --
           isDead or -- don't move dead NPCS
           isHostile or --
           followers[obj.id] or -- ignore followers
           isVampire or --
           isWerewolf or --
           (obj.class and obj.class.id == "Dreamers") --
end

-- checks NPC class and faction in cells for block list and adds to publicHouse list
local function isPublicHouse(cell)
    local npcs = {factions = {}, total = 0}
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        -- Check for NPCS of ignored classes first
        if not isIgnoredNPC(npc) and (npc.object.class and config.ignored[npc.object.class.id]) then
            log(common.logLevels.medium, "NPC:\'%s\' of class:\'%s\' made %s public", npc.object.name,
                npc.object.class and npc.object.class.id or "none", cell.name)

            createPublicHouseTableEntry(cell, npc)

            return true
        end

        local faction = npc.object.faction-- and npc.object.faction.id

        if faction then
            if not npcs.factions[faction] then npcs.factions[faction] = {total = 0, percentage = 0} end

            if not npcs.factions[faction].master or npcs.factions[faction].master.object.factionIndex < npc.object.factionIndex then
                npcs.factions[faction].master = npc
            end

            npcs.factions[faction].total = npcs.factions[faction].total + 1
        end

        npcs.total = npcs.total + 1

    end

    -- no NPCs of ignored classes, so let's check out factions
    for faction, info in pairs(npcs.factions) do
        info.percentage = ( info.total / npcs.total ) * 100
        log(common.logLevels.large,
            "No NPCs of ignored class in %s, checking faction %s (ignored: %s, player joined: %s) with %s (%s%%) vs total %s", cell.name,
            faction, config.ignored[faction.id], faction.playerJoined, info.total, info.percentage, npcs.total)

        -- less than 3 NPCs can't possibly be a public house unless it's a Blades house
        if ( config.ignored[faction.id] or faction.playerJoined ) and (npcs.total >= config.minimumOccupancy or faction == "Blades") and
            info.percentage >= config.factionIgnorePercentage then
            log(common.logLevels.medium, "%s is %s%% faction %s, marking public.", cell.name, info.percentage,
                faction)

            createPublicHouseTableEntry(cell, npcs.factions[faction].master)
            return true
        end
    end

    log(common.logLevels.large, "%s isn't public", cell.name)
    return false
end

-- todo: check cell contents to decide if it should be locked
local function isIgnoredDoor(door, homeCellId)
    -- don't lock non-cell change doors
    if not door.destination then
        log(common.logLevels.large, "Non-Cell-change door %s, ignoring", door.id)
        return true
    end

    -- Only doors in cities and towns (cells whose names share the same first characters)
    -- todo: if destination cell name contains outside cell name
    local inCity = string.sub(homeCellId, 1, 4) == string.sub(door.destination.cell.id, 1, 4)

    -- peek inside doors to look for guild halls, inns and clubs
    local leadsToPublicCell = isPublicHouse(door.destination.cell)

    local hasOccupants = false
    for npc in door.destination.cell:iterateReferences(tes3.objectType.npc) do
        if not isIgnoredNPC(npc) then
            hasOccupants = true
            -- break
        end
    end

    log(common.logLevels.large, "%s is %s, %s is %s (%sin a city, is %spublic)", door.destination.cell.id,
        config.ignored[door.destination.cell.id] and "ignored" or "not ignored", door.destination.cell.sourceMod,
        config.ignored[door.destination.cell.sourceMod] and "ignored" or "not ignored", inCity and "" or "not ",
        leadsToPublicCell and "" or "not ")

    return config.ignored[door.destination.cell.id] or config.ignored[door.destination.cell.sourceMod] or not inCity or
               leadsToPublicCell or not hasOccupants
end

local function isIgnoredCell(cell)
    log(common.logLevels.large, "%s is %s, %s is %s", cell.id, config.ignored[cell.id] and "ignored" or "not ignored",
        cell.sourceMod, config.ignored[cell.sourceMod] and "ignored" or "not ignored")

    -- don't do things in the wilderness
    -- local wilderness = false
    -- if not cell.name then wilderness = true end

    return config.ignored[cell.id] or config.ignored[cell.sourceMod] -- or wilderness
end

local function checkInteriorCell(cell)
    if not cell then return end

    log(common.logLevels.large, "Cell: interior: %s, behaves as exterior: %s therefore returning %s", cell.isInterior,
        cell.behavesAsExterior, cell.isInterior and not cell.behavesAsExterior)

    return cell.isInterior and not cell.behavesAsExterior
end

local function checkCantonCell(cellName)
    for _, str in pairs(waistworks) do if cellName:match(str) then return true end end
    return false
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
local function badWeatherNPC(npc)
    if not npc.object then return end

    log(common.logLevels.large, "NPC Inclement Weather: %s is %s, %s", npc.object.name, npc.object.class.name,
        npc.object.race.id)

    return npc.object.class.name == "Caravaner" or npc.object.class.name == "Gondolier" or npc.object.race.id ==
               "Argonian"
end

-- }}}

-- {{{ cell change checks

local function checkEnteredSpawnedNPCHome(cell)
    local home = homedNPCS[cell.id]
    if home then
        local message = string.format("Entering home of %s, %s", home.name, home.homeName)
        log(common.logLevels.medium, message)
        tes3.messageBox(message)
    end
end

local function checkEnteredPublicHouse(cell, city)
    local type = pickPublicHouseType(cell.name)

    local publicHouse = publicHouses[city] and (publicHouses[city][type] and publicHouses[city][type][cell.name])
    if publicHouse then
        local message = string.format("Entering public space %s, a%s %s in the town of %s. Talk to %s, %s for services.",
            publicHouse.name, common.vowel(type), type:gsub("s$", ""), publicHouse.city, publicHouse.proprietor.object.name,
            publicHouse.proprietor.object.class)
        log(common.logLevels.small, message)
        tes3.messageBox(message)
    end
end

-- }}}

-- }}}

-- {{{ real meat and potatoes functions
local function moveNPC(data)
    -- movedNPCs[#movedNPCs + 1] = data
    -- table.insert(movedNPCs, data)
    -- interop.setMovedNPCsTable(movedNPCs)
    table.insert(tes3.player.data.NPCsGoHome.movedNPCs, data)
    interop.setMovedNPCsTable(tes3.player.data.NPCsGoHome.movedNPCs)

    tes3.positionCell({
        cell = data.home,
        reference = data.npc,
        position = data.homePosition,
        orientation = data.homeOrientation
    })

    log(common.logLevels.small, "Moving %s to home %s (%s, %s, %s)", data.npc.object.name, data.home.id,
        data.homePosition.x, data.homePosition.y, data.homePosition.z)
end

local function putNPCsBack()
    -- for i = #movedNPCs, 1, -1 do
    for i = #tes3.player.data.NPCsGoHome.movedNPCs, 1, -1 do
        -- local data = table.remove(movedNPCs, i)
        local data = table.remove(tes3.player.data.NPCsGoHome.movedNPCs, i)
        log(common.logLevels.medium, "Moving %s back outside to %s (%s, %s, %s)", data.npc.object.name, data.ogPlace.id,
            data.ogPosition.x, data.ogPosition.y, data.ogPosition.z)
        tes3.positionCell({
            cell = data.ogPlace,
            reference = data.npc,
            position = data.ogPosition,
            orientation = data.ogPlace
        })
        -- interop.setMovedNPCsTable(movedNPCs)
        interop.setMovedNPCsTable(tes3.player.data.NPCsGoHome.movedNPCs)
    end
end

-- todo: rename to toggleNPCs(cell, state = true|false)
-- todo: using tes3.setEnabled({ enabled = state })
local function disableNPCs(cell)
    if not config.disableNPCs then return end

    -- iterate NPCs in the cell, move them to their homes, and keep track of moved NPCs so we can move them back later
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        -- for npc, _ in pairs(cellsInMemory[cell].npcs) do
        if not isIgnoredNPC(npc) then
            log(common.logLevels.large, "People change")

            -- find NPC homes
            local npcHome = config.moveNPCs and pickHomeForNPC(cell, npc) or nil

            local tmpLogLevelNPCHome = npcHome and common.logLevels.small or common.logLevels.medium
            log(tmpLogLevelNPCHome, "%s %s %s%s", npc.object.name,
                npcHome and (npcHome.isHome and "lives in" or "goes to") or "lives",
                npcHome and npcHome.home or "nowhere", npcHome and (npcHome.isHome and "." or " at night."))

            -- disable or move NPCs
            if (checkTime() or
                (checkWeather(cell) and
                    (not badWeatherNPC(npc) or (badWeatherNPC(npc) and not config.keepBadWeatherNPCs)))) then
                if npcHome then
                    moveNPC(npcHome)
                else
                    log(common.logLevels.medium, "Disabling homeless %s", npc.object.name)
                    -- npc:disable() -- ! this one sometimes causes crashes
                    mwscript.disable({reference = npc}) -- ! this one is deprecated
                    -- tes3.setEnabled({reference = npc, enabled = false}) -- ! but this one causes crashes too
                end
            else
                if not npcHome then
                    log(common.logLevels.medium, "Enabling homeless %s", npc.object.name)
                    -- npc:enable()
                    mwscript.enable({reference = npc})
                    -- tes3.setEnabled({reference = npc, enabled = true})
                end
            end
        end
    end

    -- now put NPCs back
    -- if not (checkTime() or checkWeather(cell)) and #movedNPCs > 0 then putNPCsBack() end
    if not (checkTime() or checkWeather(cell)) and #tes3.player.data.NPCsGoHome.movedNPCs > 0 then putNPCsBack() end
end

local function disableSiltStriders(cell)
    if not config.disableNPCs then return end

    log(common.logLevels.large, "Looking for silt striders")
    for activator in cell:iterateReferences(tes3.objectType.activator) do
        log(common.logLevels.large, "Is %s a silt strider??", activator.object.id)
        if activator.object.id:match("siltstrider") then
            if checkTime() or (checkWeather(cell) and not config.keepBadWeatherNPCs) then
                log(common.logLevels.medium, "Disabling silt strider %s!", activator.object.name)
                mwscript.disable({reference = activator})
                -- activator:disable()
                -- tes3.setEnabled({reference = activator, enabled = false})
            else
                log(common.logLevels.medium, "Enabling silt strider %s!", activator.object.name)
                mwscript.enable({reference = activator})
                -- activator:enable()
                -- tes3.setEnabled({reference = activator, enabled = true})
            end
        end
    end
    log(common.logLevels.large, "Done with silt striders")
end

local function processDoors(cell)
    if not config.lockDoors then return end

    log(common.logLevels.large, "Checking out doors")

    for door in cell:iterateReferences(tes3.objectType.door) do
        if not door.data.NPCsGoHome then door.data.NPCsGoHome = {} end
        log(common.logLevels.large, "Door has destination: %s", door.destination and door.destination.cell.id or "none")

        if not isIgnoredDoor(door, cell.id) then
            log(common.logLevels.large, "It knows there's a door")

            local alreadyLocked = tes3.getLocked({reference = door})
            door.data.NPCsGoHome.alreadyLocked = alreadyLocked
            log(common.logLevels.large, "Locked Status: %s", alreadyLocked)

            if checkTime() then
                if not door.data.NPCsGoHome.alreadyLocked then
                    log(common.logLevels.large, "It should lock now")
                    log(common.logLevels.large, "What door is this anyway: %s to %s", door.object.name,
                        door.destination.cell.id)

                    local lockLevel = math.random(25, 100)
                    tes3.lock({reference = door, level = lockLevel})
                    door.data.NPCsGoHome.modified = true
                end
            else
                if door.data.NPCsGoHome and door.data.NPCsGoHome.modified then
                    door.data.NPCsGoHome.modified = false
                    tes3.setLockLevel({reference = door, level = 0})
                    tes3.unlock({reference = door})

                    log(common.logLevels.large, "It should unlock now")
                    log(common.logLevels.large, "What unlocked door is this anyway: %s to %s", door.object.name,
                        door.destination.cell.id)
                end
            end

            log(common.logLevels.large, "Now Locked Status: %s", tes3.getLocked({reference = door}))
        end
    end
    log(common.logLevels.large, "Done with doors")
end

local function applyChanges(cell)
    if not cell then cell = tes3.getPlayerCell() end

    -- build our followers list
    for friend in tes3.iterate(tes3.mobilePlayer.friendlyActors) do
        local obj
        if friend.object.baseObject then
            obj = friend.object.baseObject
        else
            obj = friend.object
        end

        if friend ~= tes3.mobilePlayer then
            followers[obj.id] = true
            -- log(common.logLevels.large, "%s is follower", obj.id)
        end
    end

    if isIgnoredCell(cell) then return end

    -- Interior cell, except Waistworks, don't do anything
    if checkInteriorCell(cell) and not (config.waistWorks and checkCantonCell(cell.name)) then return end

    -- Disable NPCs in cell
    disableNPCs(cell)
    disableSiltStriders(cell)

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

local function updatePlayerTrespass(cell)
    cell = cell or tes3.getPlayerCell()

    if checkInteriorCell(cell) and not isIgnoredCell(cell) and not isPublicHouse(cell) then
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
    if e.activator ~= tes3.player or
       e.target.object.objectType ~= tes3.objectType.npc or
       not config.disableInteraction then
        return
    end

    if tes3.player.data.NPCsGoHome.intruding and not isIgnoredNPC(e.target) then
        tes3.messageBox(string.format("%s: Get out before I call the guards!", e.target.object.name))
        return false
    end
end

local function onLoaded()
    if not tes3.player.data.NPCsGoHome then tes3.player.data.NPCsGoHome = {} end
    if not tes3.player.data.NPCsGoHome.movedNPCs then tes3.player.data.NPCsGoHome.movedNPCs = {} end
    -- movedNPCs = {}

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
    updatePlayerTrespass(e.cell)
    checkEnteredSpawnedNPCHome(e.cell)
    if e.cell.name then -- exterior wilderness cells don't have name
        checkEnteredPublicHouse(e.cell, common.split(e.cell.name, ",")[1])
    end

    --[[
    -- ! delete this
    if config.logLevel == common.logLevels.none then
        if (e.previousCell and e.previousCell.name and e.previousCell.name ~= e.cell.name) then
            mwse.log("}\n[\"%s\"] = {", e.cell.id)
        elseif not e.previousCell then
            mwse.log("[\"%s\"] = {", e.cell.id)
        end
    end
    -- ! ]]
end
-- }}}

-- {{{ event registering
event.register("loaded", onLoaded)
event.register("cellChanged", onCellChanged)

event.register("activate", onActivated)

event.register("modConfigReady", function() mwse.mcm.register(require("celediel.NPCsGoHome.mcm")) end)
-- }}}

-- vim:fdm=marker
