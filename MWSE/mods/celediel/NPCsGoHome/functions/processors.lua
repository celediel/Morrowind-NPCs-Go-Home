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

this.updatePositions = function(cell)
    local id = cell.id
    -- update runtime positions in cell, but don't overwrite loaded positions
    if not common.runtimeData.positions[id] and positions.cells[id] then
        common.runtimeData.positions[id] = {}
        for _, data in pairs(positions.cells[id]) do
            table.insert(common.runtimeData.positions[id], data)
        end
    end
end

this.searchCellsForPositions = function()
    for _, cell in pairs(tes3.getActiveCells()) do
        -- check active cells
        this.updatePositions(cell)
        for door in cell:iterateReferences(tes3.objectType.door) do
            if door.destination then
                -- then check cells attached to active cells
                this.updatePositions(door.destination.cell)
                -- one more time
                for internalDoor in door.destination.cell:iterateReferences(tes3.objectType.door) do
                    if internalDoor.destination then this.updatePositions(internalDoor.destination.cell) end
                end
            end
        end
    end
end

-- search in a specific cell for moved NPCs
this.checkForMovedNPCs = function(cell)
    -- NPCs don't get moved to exterior cells, so no need to check them for moved NPCs
    if not checks.isInteriorCell(cell) then return end

    log(common.logLevels.medium, "Looking for moved NPCs in cell %s", cell.id)
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        if npc.data and npc.data.NPCsGoHome then
            dataTables.createHomedNPCTableEntry(npc, cell, tes3.getCell(npc.data.NPCsGoHome.cell), true, npc.data.NPCsGoHome.position, npc.data.NPCsGoHome.orientation)
        end
    end
end

this.searchCellsForNPCs = function()
    for _, cell in pairs(tes3.getActiveCells()) do
        -- check active cells
        this.checkForMovedNPCs(cell)
        for door in cell:iterateReferences(tes3.objectType.door) do
            if door.destination then
                -- then check cells attached to active cells
                this.checkForMovedNPCs(door.destination.cell)
            end
        end
    end
end

this.moveNPC = function(homeData)
    -- add to in memory table
    table.insert(common.runtimeData.movedNPCs, homeData)
    interop.setRuntimeData(common.runtimeData)

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

this.putNPCsBack = function()
    for i = #common.runtimeData.movedNPCs, 1, -1 do
        local data = table.remove(common.runtimeData.movedNPCs, i)
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
    interop.setRuntimeData(common.runtimeData)
end

this.processNPCs = function(cell)
    -- todo: move this check somewhere else, so that disabled NPCs will be re-enabled even if the option is off
    if not config.disableNPCs then return end

    log(common.logLevels.small, "Looking for NPCs to process in cell:%s", cell.id)

    -- iterate NPCs in the cell, move them to their homes, and keep track of moved NPCs so we can move them back later
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        -- for npc, _ in pairs(cellsInMemory[cell].npcs) do
        if not checks.isIgnoredNPC(npc) then
            log(common.logLevels.large, "People change")
            -- if not npc.data.NPCsGoHome then npc.data.NPCsGoHome = {} end

            -- find NPC homes
            local npcHome = config.moveNPCs and housing.pickHomeForNPC(cell, npc) or nil

            local tmpLogLevelNPCHome = npcHome and common.logLevels.medium or common.logLevels.large
            log(tmpLogLevelNPCHome, "%s %s %s%s", npc.object.name,
                npcHome and (npcHome.isHome and "lives in" or "goes to") or "lives",
                npcHome and npcHome.home or "nowhere", npcHome and (npcHome.isHome and "." or " at night.") or ".")

            -- disable or move NPCs
            if (checks.checkTime() or
                (checks.checkWeather(cell) and
                    (not checks.isBadWeatherNPC(npc) or (checks.isBadWeatherNPC(npc) and not config.keepBadWeatherNPCs)))) then
                if npcHome then
                    this.moveNPC(npcHome)
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
    -- if not (checks.checkTime() or checks.checkWeather(cell)) and #movedNPCs > 0 then putNPCsBack() end
    if not (checks.checkTime() or checks.checkWeather(cell)) then this.putNPCsBack() end
end

this.processSiltStriders = function(cell)
    if not config.disableNPCs then return end

    log(common.logLevels.small, "Looking for silt striders to process in cell:%s", cell.name)
    for activator in cell:iterateReferences(tes3.objectType.activator) do
        log(common.logLevels.large, "Is %s a silt strider??", activator.object.id)
        if activator.object.id:match("siltstrider") then
            if checks.checkTime() or (checks.checkWeather(cell) and not config.keepBadWeatherNPCs) then
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
this.processPets = function(cell)
    if not config.disableNPCs then return end

    log(common.logLevels.small, "Looking for NPC pets to process in cell:%s", cell.name)

    for creature in cell:iterateReferences(tes3.objectType.creature) do
        if checks.isNPCPet(creature) then
            if checks.checkTime() then
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

this.processDoors = function(cell)
    if not config.lockDoors then return end

    log(common.logLevels.small, "Looking for doors to process in cell:%s", cell.id)

    for door in cell:iterateReferences(tes3.objectType.door) do
        if not door.data.NPCsGoHome then door.data.NPCsGoHome = {} end

        if not checks.isIgnoredDoor(door, cell.id) then
            -- don't mess around with doors that are already locked
            if door.data.NPCsGoHome.alreadyLocked == nil then
                door.data.NPCsGoHome.alreadyLocked = tes3.getLocked({reference = door})
            end

            log(common.logLevels.large, "Found %slocked %s with destination %s",
                door.data.NPCsGoHome.alreadyLocked and "" or "un", door.id, door.destination.cell.id)

            if checks.checkTime() then
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

return this
