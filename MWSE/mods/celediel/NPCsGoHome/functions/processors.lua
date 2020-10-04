-- handles processing NPCs, their pets/mounts, doors
local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local checks = require("celediel.NPCsGoHome.functions.checks")
local interop = require("celediel.NPCsGoHome.interop")
local housing = require("celediel.NPCsGoHome.functions.housing")
local dataTables = require("celediel.NPCsGoHome.functions.dataTables")
local positions = require("celediel.NPCsGoHome.data.positions")

local function log(level, ...) if config.logLevel >= level then common.log(...) end end

local this = {}

local function moveNPC(homeData)
    local npc = homeData.npc

    -- add to in memory table
    local badWeather = checks.isBadWeatherNPC(npc)
    if badWeather then
        table.insert(common.runtimeData.movedBadWeatherNPCs, homeData)
    else
        table.insert(common.runtimeData.movedNPCs, homeData)
    end
    interop.setRuntimeData(common.runtimeData)

    -- set npc data, so we can move NPCs back after a load
    npc.data.NPCsGoHome = {
        position = {x = npc.position.x, y = npc.position.y, z = npc.position.z},
        orientation = {x = npc.orientation.x, y = npc.orientation.y, z = npc.orientation.z},
        cell = homeData.ogPlaceName
    }

    tes3.positionCell({
        cell = homeData.home,
        reference = homeData.npc,
        position = homeData.homePosition,
        orientation = homeData.homeOrientation
    })

    log(common.logLevels.medium, "[PROC] Moving %s to home %s (%s, %s, %s)", homeData.npc.object.name, homeData.home.id,
        homeData.homePosition.x, homeData.homePosition.y, homeData.homePosition.z)
end

local function disableNPC(npc)
    -- same thing as moveNPC, but disables instead
    -- add to runtimeData
    if checks.isBadWeatherNPC(npc) then
        -- table.insert(common.runtimeData.disabledBadWeatherNPCs, npc)
        common.runtimeData.disabledBadWeatherNPCs[npc.id] = npc
    else
        -- table.insert(common.runtimeData.disabledNPCs, npc)
        common.runtimeData.disabledNPCs[npc.id] = npc
    end
    -- set NPC data
    npc.data.NPCsGoHome = {disabled = true}
    -- disable NPC
    -- npc:disable() -- ! this one sometimes causes crashes
    mwscript.disable({reference = npc}) -- ! this one is deprecated
    -- tes3.setEnabled({reference = npc, enabled = false}) -- ! but this one causes crashes too
    -- do some logging
    log(common.logLevels.medium, "[PROC] Disabling un-homed %s", npc.name and npc.name or npc.id)
end

local function putNPCsBack(npcData)
    for i = #npcData, 1, -1 do
        local data = table.remove(npcData, i)
        log(common.logLevels.medium, "[PROC] Moving %s back outside to %s (%s, %s, %s)", data.npc.object.name,
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
    end

    -- reset loaded position data
    common.runtimeData.positions = {}
    this.searchCellsForPositions()

    interop.setRuntimeData(common.runtimeData)
end

local function reEnableNPCs(npcs)
    for id, ref in pairs(npcs) do
        log(common.logLevels.medium, "[PROC] Enabling homeless %s", ref.object.name)

        -- ref:enable()
        mwscript.enable({reference = ref})
        ref.data.NPCsGoHome = nil
        npcs[id] = nil
    end

    interop.setRuntimeData(common.runtimeData)
end

local function disableOrMove(npc, cell)
    -- check for home
    local npcHome = config.moveNPCs and housing.pickHomeForNPC(cell, npc) or nil
    if npcHome then
        moveNPC(npcHome)
    elseif cell.name or (not cell.name and config.disableNPCsInWilderness) then
        -- todo: re-enable NPCs in wilderness if this config option is changed
        disableNPC(npc)
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
    -- NPCs don't get moved to exterior cells, so no need to check them for moved NPCs
    -- NPCs do get disabled in interior cells though
    -- if not checks.isInteriorCell(cell) then return end

    log(common.logLevels.medium, "[PROC] Looking for moved NPCs in cell %s", cell.id)
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        if npc.data and npc.data.NPCsGoHome then
            log(common.logLevels.large, "[PROC] %s has NPCsGoHome data, deciding if disabled or moved...%s", npc,
                json.encode(npc.data.NPCsGoHome))
            local badWeather = checks.isBadWeatherNPC(npc)
            if npc.data.NPCsGoHome.disabled then
                -- disabled NPC
                if badWeather then
                    common.runtimeData.disabledBadWeatherNPCs[npc.id] = npc
                    -- table.insert(common.runtimeData.disabledBadWeatherNPCs, npc)
                else
                    common.runtimeData.disabledNPCs[npc.id] = npc
                    -- table.insert(common.runtimeData.disabledNPCs, npc)
                end
            else
                -- homed NPC
                local homeData = dataTables.createHomedNPCTableEntry(npc, cell,
                                                                     tes3.getCell({id = npc.data.NPCsGoHome.cell}),
                                                                     true, npc.data.NPCsGoHome.position,
                                                                     npc.data.NPCsGoHome.orientation)

                -- add to in memory table
                if badWeather then
                    table.insert(common.runtimeData.movedBadWeatherNPCs, homeData)
                else
                    table.insert(common.runtimeData.movedNPCs, homeData)
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
                    if internalDoor.destination then updatePositions(internalDoor.destination.cell) end
                end
            end
        end
    end
end

this.processNPCs = function(cell)
    local night = checks.isNight()
    local badWeather = checks.isInclementWeather()

    log(common.logLevels.small, "[PROC] Looking for NPCs to process in cell:%s", cell.id)

    if badWeather and not night then
        log(common.logLevels.medium, "[PROC] !!Bad weather and not night!!")
        -- bad weather during the day, so disable some NPCs
        for npc in cell:iterateReferences(tes3.objectType.npc) do
            if not checks.isIgnoredNPC(npc) then
                local keep = checks.isBadWeatherNPC(npc)
                if not keep or not config.keepBadWeatherNPCs then disableOrMove(npc, cell) end
            end
        end

        -- LuaFormatter off
        -- check for bad weather NPCs that have been disabled, and re-enable them
        if not common.isEmptyTable(common.runtimeData.movedBadWeatherNPCs) then putNPCsBack(common.runtimeData.movedBadWeatherNPCs) end
        if not common.isEmptyTable(common.runtimeData.disabledBadWeatherNPCs) then reEnableNPCs(common.runtimeData.disabledBadWeatherNPCs) end
    elseif night then
        log(common.logLevels.medium, "[PROC] !!Good or bad weather and night!!")
        -- at night, weather doesn't matter, disable everyone
        for npc in cell:iterateReferences(tes3.objectType.npc) do
            if not checks.isIgnoredNPC(npc) then disableOrMove(npc, cell) end
        end
    else
        log(common.logLevels.medium, "[PROC] !!Good weather and not night!!")
        -- put everyone back
        if not common.isEmptyTable(common.runtimeData.movedNPCs) then putNPCsBack(common.runtimeData.movedNPCs) end
        if not common.isEmptyTable(common.runtimeData.movedBadWeatherNPCs) then putNPCsBack(common.runtimeData.movedBadWeatherNPCs) end
        if not common.isEmptyTable(common.runtimeData.disabledNPCs) then reEnableNPCs(common.runtimeData.disabledNPCs) end
        if not common.isEmptyTable(common.runtimeData.disabledBadWeatherNPCs) then reEnableNPCs(common.runtimeData.disabledBadWeatherNPCs) end
        -- LuaFormatter on
    end
end

this.processSiltStriders = function(cell)
    if not config.disableNPCs then return end

    log(common.logLevels.small, "[PROC] Looking for silt striders to process in cell:%s", cell.name)
    for activator in cell:iterateReferences(tes3.objectType.activator) do
        log(common.logLevels.large, "[PROC] Is %s a silt strider??", activator.object.id)
        if activator.object.id:match("siltstrider") then
            if checks.isNight() or (checks.isInclementWeather() and not config.keepBadWeatherNPCs) then
                if not activator.disabled then
                    log(common.logLevels.medium, "[PROC] Disabling silt strider %s!", activator.object.name)
                    mwscript.disable({reference = activator})
                    -- activator:disable()
                    -- tes3.setEnabled({reference = activator, enabled = false})
                end
            else
                if activator.disabled then
                    log(common.logLevels.medium, "[PROC] Enabling silt strider %s!", activator.object.name)
                    mwscript.enable({reference = activator})
                    -- activator:enable()
                    -- tes3.setEnabled({reference = activator, enabled = true})
                end
            end
        end
    end
    log(common.logLevels.large, "[PROC] Done with silt striders")
end

-- deal with trader's guars, and other npc linked creatures/whatever
this.processPets = function(cell)
    if not config.disableNPCs then return end
    local night = checks.isNight()
    local badWeather = checks.isInclementWeather()

    log(common.logLevels.small, "[PROC] Looking for NPC pets to process in cell:%s", cell.name)

    for creature in cell:iterateReferences(tes3.objectType.creature) do
        local isPet, linkedToTravel = checks.isNPCPet(creature)
        if isPet then
            if night or (badWeather and (not linkedToTravel or (linkedToTravel and not config.keepBadWeatherNPCs))) then
                -- disable
                if not creature.disabled then
                    log(common.logLevels.medium, "[PROC] Disabling NPC Pet %s!", creature.object.id)
                    mwscript.disable({reference = creature})
                end
            else
                -- enable
                if creature.disabled then
                    log(common.logLevels.medium, "[PROC] Enabling NPC Pet %s!", creature.object.id)
                    mwscript.enable({reference = creature})
                end
            end
        end
    end
end

this.processDoors = function(cell)
    if not config.lockDoors then return end
    local night = checks.isNight()

    log(common.logLevels.small, "[PROC] Looking for doors to process in cell:%s", cell.id)

    for door in cell:iterateReferences(tes3.objectType.door) do
        if not door.data.NPCsGoHome then door.data.NPCsGoHome = {} end

        if not checks.isIgnoredDoor(door, cell.id) then
            -- don't mess around with doors that are already locked
            if door.data.NPCsGoHome.alreadyLocked == nil then
                door.data.NPCsGoHome.alreadyLocked = tes3.getLocked({reference = door})
            end

            log(common.logLevels.large, "[PROC] Found %slocked %s with destination %s",
                door.data.NPCsGoHome.alreadyLocked and "" or "un", door.id, door.destination.cell.id)

            if night then
                if not door.data.NPCsGoHome.alreadyLocked then
                    log(common.logLevels.medium, "[PROC] locking: %s to %s", door.object.name, door.destination.cell.id)

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

                    log(common.logLevels.medium, "[PROC] unlocking: %s to %s", door.object.name,
                        door.destination.cell.id)
                end
            end

            log(common.logLevels.large, "[PROC] Now locked Status: %s", tes3.getLocked({reference = door}))
        end
    end
    log(common.logLevels.large, "[PROC] Done with doors")
end

return this
