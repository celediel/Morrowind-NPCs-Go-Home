-- handles processing NPCs, their pets/mounts, doors
local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local checks = require("celediel.NPCsGoHome.functions.checks")
local housing = require("celediel.NPCsGoHome.functions.housing")
local dataTables = require("celediel.NPCsGoHome.functions.dataTables")
local positions = require("celediel.NPCsGoHome.data.positions")

local function log(level, ...) if config.logLevel >= level then common.log(...) end end

local this = {}

-- iterators
-- in common maybe?
local function iterateNPCs(cell)
    local function iterator()
        for npc in cell:iterateReferences(tes3.objectType.npc) do
            if not checks.isIgnoredNPC(npc) then
                local keep = checks.isBadWeatherNPC(npc)
                coroutine.yield(npc, keep)
            end
        end
    end
    return coroutine.wrap(iterator)
end

local function iterateSilts(cell)
    local function iterator()
        for activator in cell:iterateReferences(tes3.objectType.activator) do
            if checks.isSiltStrider(activator) then coroutine.yield(activator) end
        end
    end
    return coroutine.wrap(iterator)
end

local function iterateDoors(cell)
    local function iterator()
        for door in cell:iterateReferences(tes3.objectType.door) do
            if not checks.isIgnoredDoor(door, cell.id) then coroutine.yield(door) end
        end
    end
    return coroutine.wrap(iterator)
end

local function iteratePets(cell)
    local function iterator()
        for creature in cell:iterateReferences(tes3.objectType.creature) do
            local isPet, linkedToTravel = checks.isNPCPet(creature)
            if isPet then coroutine.yield(creature, linkedToTravel) end
        end
    end
    return coroutine.wrap(iterator)
end

local function moveNPC(homeData)
    -- do some logging
    log(common.logLevels.medium, "[PROC:NPCS] Moving %s to home %s (%s, %s, %s)", homeData.npc.object.name,
        homeData.home.id, homeData.homePosition.x, homeData.homePosition.y, homeData.homePosition.z)

    local npc = homeData.npc

    -- add to in memory table
    local badWeather = checks.isBadWeatherNPC(npc)
    if badWeather then
        common.runtimeData.NPCs.movedBadWeather[homeData.ogPlaceName] =
            common.runtimeData.NPCs.movedBadWeather[homeData.ogPlaceName] or {}
        common.runtimeData.NPCs.movedBadWeather[homeData.ogPlaceName][npc.id] = homeData
    else
        common.runtimeData.NPCs.moved[homeData.ogPlaceName] = common.runtimeData.NPCs.moved[homeData.ogPlaceName] or {}
        common.runtimeData.NPCs.moved[homeData.ogPlaceName][npc.id] = homeData
    end

    -- set npc data, so we can move NPCs back after a load
    npc.data.NPCsGoHome = {
        position = {x = npc.position.x, y = npc.position.y, z = npc.position.z},
        orientation = {x = npc.orientation.x, y = npc.orientation.y, z = npc.orientation.z},
        cell = homeData.ogPlaceName
    }

    -- do the move
    tes3.positionCell({
        cell = homeData.home,
        reference = homeData.npc,
        position = homeData.homePosition,
        orientation = homeData.homeOrientation
    })
end

local function disableNPC(npc, cell)
    -- do some logging
    log(common.logLevels.medium, "[PROC:NPCS] Disabling un-homed %s", npc.name and npc.name or npc.id)
    -- add to runtimeData
    if checks.isBadWeatherNPC(npc) then
        common.runtimeData.NPCs.disabledBadWeather[cell.id] = common.runtimeData.NPCs.disabledBadWeather[cell.id] or {}
        common.runtimeData.NPCs.disabledBadWeather[cell.id][npc.id] = npc
    else
        common.runtimeData.NPCs.disabled[cell.id] = common.runtimeData.NPCs.disabled[cell.id] or {}
        common.runtimeData.NPCs.disabled[cell.id][npc.id] = npc
    end
    -- set NPC data
    npc.data.NPCsGoHome = {disabled = true}
    -- disable NPC
    -- npc:disable() -- ! this one sometimes causes crashes
    mwscript.disable({reference = npc}) -- ! this one is deprecated
    -- tes3.setEnabled({reference = npc, enabled = false}) -- ! but this one causes crashes too
end

local function putNPCsBack(npcData)
    log(common.logLevels.medium, "[PROC:NPCS] Moving back NPCs:\n%s", common.inspect(npcData))
    -- for i = #npcData, 1, -1 do
    for id, data in pairs(npcData) do
        if data.npc.object then
            -- local data = table.remove(npcData, i)
            log(common.logLevels.medium, "[PROC:NPCS] Moving %s back outside to %s (%s, %s, %s)", data.npc.object.name,
                data.ogPlace.id, data.ogPosition.x, data.ogPosition.y, data.ogPosition.z)

            -- unset NPC data so we don't try to move them on load
            data.npc.data.NPCsGoHome = nil

            -- and put them back
            tes3.positionCell({
                cell = data.ogPlace,
                reference = data.npc,
                position = data.ogPosition,
                orientation = data.ogPlace
            })
            npcData[id] = nil
        end
    end

    -- reset loaded position data
    common.runtimeData.positions = {}
    this.searchCellsForPositions()
end

local function reEnableNPCs(npcs)
    log(common.logLevels.medium, "[PROC:NPCS] Re-enabling NPCs:\n%s", common.inspect(npcs))
    for id, ref in pairs(npcs) do
        log(common.logLevels.medium, "[PROC:NPCS] Making attempt at re-enabling %s", id)
        if ref.object and ref.disabled then

            -- ref:enable()
            mwscript.enable({reference = ref})
            ref.data.NPCsGoHome = nil
            npcs[id] = nil
        end
    end
end

local function disableOrMove(npc, cell)
    -- check for home
    local npcHome = config.moveNPCs and housing.pickHomeForNPC(cell, npc) or nil
    if npcHome then
        moveNPC(npcHome)
    else
        disableNPC(npc, cell)
    end
end

-- create an in memory list of positions for a cell, to ensure multiple NPCs aren't placed in the same spot
local function updatePositions(cell)
    local id = cell.id
    -- update runtime positions in cell, but don't overwrite loaded positions
    if not common.runtimeData.positions[id] and positions.cells[id] then
        common.runtimeData.positions[id] = {}
        for _, data in pairs(positions.cells[id]) do table.insert(common.runtimeData.positions[id], data) end
    end
end

-- search in a specific cell for moved or disabled NPCs
local function checkForMovedOrDisabledNPCs(cell)
    log(common.logLevels.medium, "[PROC:NPCS] Looking for moved NPCs in cell %s", cell.id)
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        if npc.data and npc.data.NPCsGoHome then
            log(common.logLevels.large, "[PROC:NPCS] %s has NPCsGoHome data, deciding if disabled or moved...%s", npc,
                common.inspect(npc.data.NPCsGoHome))
            local badWeather = checks.isBadWeatherNPC(npc)
            if npc.data.NPCsGoHome.disabled then
                -- disabled NPC
                if badWeather then
                    common.runtimeData.NPCs.disabledBadWeather[cell.id] =
                        common.runtimeData.NPCs.disabledBadWeather[cell.id] or {}
                    common.runtimeData.NPCs.disabledBadWeather[cell.id][npc.id] = npc
                else
                    common.runtimeData.NPCs.disabled[cell.id] = common.runtimeData.NPCs.disabled[cell.id] or {}
                    common.runtimeData.NPCs.disabled[cell.id][npc.id] = npc
                end
            else
                -- homed NPC
                local homeData = dataTables.createHomedNPCTableEntry(npc, cell,
                                                                     tes3.getCell({id = npc.data.NPCsGoHome.cell}),
                                                                     true, npc.data.NPCsGoHome.position,
                                                                     npc.data.NPCsGoHome.orientation)

                -- add to in memory table
                if badWeather then
                    common.runtimeData.NPCs.movedBadWeather[homeData.ogPlaceName] =
                        common.runtimeData.NPCs.movedBadWeather[homeData.ogPlaceName] or {}
                    common.runtimeData.NPCs.movedBadWeather[homeData.ogPlaceName][npc.id] = homeData
                else
                    common.runtimeData.NPCs.moved[homeData.ogPlaceName] =
                        common.runtimeData.NPCs.moved[homeData.ogPlaceName] or {}
                    common.runtimeData.NPCs.moved[homeData.ogPlaceName][npc.id] = homeData
                end
            end
        end
    end
end

this.searchCellsForNPCs = function()
    for _, cell in pairs(tes3.getActiveCells()) do
        -- check active cells
        checkForMovedOrDisabledNPCs(cell)
        for door in cell:iterateReferences(tes3.objectType.door) do
            if door.destination then
                -- then check cells attached to active cells
                checkForMovedOrDisabledNPCs(door.destination.cell)
            end
        end
    end
end

-- todo: make this recursive?
this.searchCellsForPositions = function()
    for _, cell in pairs(tes3.getActiveCells()) do
        -- check active cells
        updatePositions(cell)
        for door in cell:iterateReferences(tes3.objectType.door) do
            if door.destination then
                -- then check cells attached to active cells
                updatePositions(door.destination.cell)
                -- one more time
                for internalDoor in door.destination.cell:iterateReferences(tes3.objectType.door) do
                    if internalDoor.destination and internalDoor.destination.cell ~= cell then
                        updatePositions(internalDoor.destination.cell)
                    end
                end
            end
        end
    end
end

this.processNPCs = function(cell)
    log(common.logLevels.small, "[PROC:NPCS] Looking for NPCs to process in cell:%s", cell.id)

    local night = checks.isNight()
    local badWeather = checks.isInclementWeather()

    if not cell.restingIsIllegal and not config.disableNPCsInWilderness then
        -- shitty way of implementing this config option and re-enabling NPCs when it gets turned off
        -- but at least it's better than trying to keep track of NPCs that have been disabled in the wilderness
        log(common.logLevels.medium, "[PROC:NPCS] Shitty hack ACTIVATE! It's now not night, and the weather is great.")
        night = false
        badWeather = false
    end

    if config.disableNPCs and badWeather and not night then
        log(common.logLevels.large, "[PROC:NPCS] !!Bad weather and not night!!")
        -- bad weather during the day, so disable some NPCs
        for npc, keep in iterateNPCs(cell) do
            if not keep or not config.keepBadWeatherNPCs then disableOrMove(npc, cell) end
        end

        -- LuaFormatter off
        -- check for bad weather NPCs that have been disabled, and re-enable them
        if config.keepBadWeatherNPCs then
            if not common.isEmptyTable(common.runtimeData.NPCs.movedBadWeather[cell.id]) then putNPCsBack(common.runtimeData.NPCs.movedBadWeather[cell.id]) end
            if not common.isEmptyTable(common.runtimeData.NPCs.disabledBadWeather[cell.id]) then reEnableNPCs(common.runtimeData.NPCs.disabledBadWeather[cell.id]) end
        end
    elseif config.disableNPCs and night then
        log(common.logLevels.large, "[PROC:NPCS] !!Good or bad weather and night!!")
        -- at night, weather doesn't matter, disable everyone
        for npc in iterateNPCs(cell) do if not npc.disabled then disableOrMove(npc, cell) end end
    else
        log(common.logLevels.large, "[PROC:NPCS] !!Good weather and not night!!")
        -- put everyone back
        if not common.isEmptyTable(common.runtimeData.NPCs.moved[cell.id]) then putNPCsBack(common.runtimeData.NPCs.moved[cell.id]) end
        if not common.isEmptyTable(common.runtimeData.NPCs.movedBadWeather[cell.id]) then putNPCsBack(common.runtimeData.NPCs.movedBadWeather[cell.id]) end
        if not common.isEmptyTable(common.runtimeData.NPCs.disabled[cell.id]) then reEnableNPCs(common.runtimeData.NPCs.disabled[cell.id]) end
        if not common.isEmptyTable(common.runtimeData.NPCs.disabledBadWeather[cell.id]) then reEnableNPCs(common.runtimeData.NPCs.disabledBadWeather[cell.id]) end
        -- LuaFormatter on
    end
end

-- todo: maybe deal with these like NPCs, adding to runtime data
-- todo: and setting ref.data.NPCsGoHome = {disabled = true}
-- todo: would have to check for them on load/cell change as well
-- todo: doors is already half done
this.processSiltStriders = function(cell)
    log(common.logLevels.small, "[PROC:SILT] Looking for silt striders to process in cell:%s", cell.id)

    local night = checks.isNight()
    local badWeather = checks.isInclementWeather()

    -- I don't think there are any silt striders in wilderness cells so not bothering with config.disableNPCsInWilderness

    if config.disableNPCs and (night or (badWeather and not config.keepBadWeatherNPCs)) then
        -- disable
        for silt in iterateSilts(cell) do
            log(common.logLevels.medium, "[PROC:SILT] Disabling silt strider %s!", silt.object.name)
            mwscript.disable({reference = silt})
        end
    else
        -- re-enable
        for silt in iterateSilts(cell) do
            log(common.logLevels.medium, "[PROC:SILT] Enabling silt strider %s!", silt.object.name)
            mwscript.enable({reference = silt})
        end
    end
    log(common.logLevels.large, "[PROC:SILT] Done with silt striders")
end

-- todo: maybe rewrite this one like processNPCs() too
-- deal with trader's guars, and other npc linked creatures/whatever
this.processPets = function(cell)
    local night = checks.isNight()
    local badWeather = checks.isInclementWeather()

    log(common.logLevels.small, "[PROC:PETS] Looking for NPC pets to process in cell:%s", cell.id)

    if not cell.restingIsIllegal and not config.disableNPCsInWilderness then
        log(common.logLevels.medium, "[PROC:PETS] Shitty hack ACTIVATE! It's now not night, and the weather is great.")
        night = false
        badWeather = false
    end

    -- for creature in cell:iterateReferences(tes3.objectType.creature) do
    for pet, linkedToTravel in iteratePets(cell) do
        -- this is becoming too much lol
        if config.disableNPCs and
            (night or (badWeather and (not linkedToTravel or (linkedToTravel and not config.keepBadWeatherNPCs)))) then
            -- disable
            if not pet.disabled then
                log(common.logLevels.medium, "[PROC:PETS] Disabling NPC Pet %s!", pet.object.id)
                mwscript.disable({reference = pet})
            end
        else
            -- enable
            if pet.disabled then
                log(common.logLevels.medium, "[PROC:PETS] Enabling NPC Pet %s!", pet.object.id)
                mwscript.enable({reference = pet})
            end
        end
    end
end

this.processDoors = function(cell)
    log(common.logLevels.small, "[PROC:DOOR] Looking for doors to process in cell:%s", cell.id)

    local night = checks.isNight()

    if config.lockDoors and night then
        -- lock
        for door in iterateDoors(cell) do
            if not door.data.NPCsGoHome then door.data.NPCsGoHome = {} end
            -- don't mess around with doors that are already locked
            if door.data.NPCsGoHome.alreadyLocked == nil then -- the one time I specifically don't want to use [ if not thing ]
                door.data.NPCsGoHome.alreadyLocked = tes3.getLocked({reference = door})
            end

            log(common.logLevels.large, "[PROC:DOOR] Found %slocked %s with destination %s",
                door.data.NPCsGoHome.alreadyLocked and "" or "un", door.id, door.destination.cell.id)

            -- it's not a door that's already locked or one we've already touched, so lock it
            if not door.data.NPCsGoHome.alreadyLocked and not door.data.NPCsGoHome.modified then
                log(common.logLevels.medium, "[PROC:DOOR] Locking: %s to %s", door.object.name, door.destination.cell.id)

                -- todo: pick this better
                local lockLevel = math.random(25, 100)
                tes3.lock({reference = door, level = lockLevel})
                door.data.NPCsGoHome.modified = true
            end

            log(common.logLevels.large, "[PROC:DOOR] Now locked Status: %s", tes3.getLocked({reference = door}))
        end
    else
        -- unlock, don't need all the extra overhead that comes along with checks.isIgnoredDoor here
        for door in cell:iterateReferences(tes3.objectType.door) do
            -- only unlock doors that we locked before
            if door.data and door.data.NPCsGoHome and door.data.NPCsGoHome.modified then
                door.data.NPCsGoHome.modified = false

                tes3.setLockLevel({reference = door, level = 0})
                tes3.unlock({reference = door})

                log(common.logLevels.medium, "[PROC:DOOR] Unlocking: %s to %s", door.object.name,
                    door.destination.cell.id)
            end
        end
    end
    log(common.logLevels.large, "[PROC:DOOR] Done with doors")
end

return this
