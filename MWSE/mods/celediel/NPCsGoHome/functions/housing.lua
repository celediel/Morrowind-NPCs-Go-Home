-- handles finding homes or picking public spaces for NPCs
-- * home cell is chosen according to the following order:
-- * NPC's actual home, i.e.: home cell name contains NPC name
local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local dataTables = require("celediel.NPCsGoHome.functions.dataTables")

local function log(level, ...) if config.logLevel >= level then common.log(...) end end

-- animated morrowind NPCs are contextual
local contextualNPCs = {"^AM_"}

local this = {}

this.livesInManor = function(cellName, npcName)
    if not cellName or (cellName and not string.find(cellName, "Manor")) then return end

    local splitName = common.split(npcName)
    local given = splitName[1]
    local sur = splitName[2]

    -- surnameless peasants don't live in manors
    if not sur then return end

    log(common.logLevels.large, "[HOUSING] Checking if %s %s lives in %s", given, sur, cellName)
    return string.match(cellName, sur)
end

this.pickInnForNPC = function(npc, city)
    -- todo: pick in Inn intelligently ?
    -- high class inns for nobles and rich merchants and such
    -- lower class inns for middle class npcs and merchants
    -- temple for commoners and the poorest people

    -- but for now pick one at random
    if common.runtimeData.publicHouses[city] and common.runtimeData.publicHouses[city][common.publicHouseTypes.inns] then
        local choice = table.choice(common.runtimeData.publicHouses[city][common.publicHouseTypes.inns])
        if not choice then return nil end
        log(common.logLevels.medium, "[HOUSING] Picking inn %s, %s for %s", choice.city, choice.name, npc.object.name)
        return choice.cell
    end
end

this.pickPublicHouseForNPC = function(npc, city)
    -- look for wandering guild members
    if common.runtimeData.publicHouses[city] and
        common.runtimeData.publicHouses[city][common.publicHouseTypes.guildhalls] then
        for _, data in pairs(common.runtimeData.publicHouses[city][common.publicHouseTypes.guildhalls]) do
            -- if npc's faction and proprietor's faction match, pick that one
            if npc.object.faction == data.proprietor.object.faction then
                log(common.logLevels.medium, "[HOUSING] Picking %s for %s based on faction", data.cell.id, npc.object.name)
                return data.cell
            end
        end
    end

    -- temple members go to the temple
    if common.runtimeData.publicHouses[city] and common.runtimeData.publicHouses[city][common.publicHouseTypes.temples] then
        for _, data in pairs(common.runtimeData.publicHouses[city][common.publicHouseTypes.temples]) do
            if npc.object.faction == data.proprietor.object.faction then
                log(common.logLevels.medium, "[HOUSING] Picking temple %s for %s based on faction", data.cell.id, npc.object.name)
                return data.cell
            end
        end
    end

    -- found nothing so pick an inn
    return this.pickInnForNPC(npc, city)
end

-- looks through doors to find a cell that matches a wandering NPCs name
this.pickHomeForNPC = function(cell, npc)
    -- don't move contextual, such as Animated Morrowind, NPCs at all
    for _, str in pairs(contextualNPCs) do if npc.object.id:match(str) then return end end

    -- time to pick the "home"
    local name = npc.object.name:gsub(" the .*$","") -- remove "the whatever" from NPCs name
    local city = cell.name and common.split(cell.name, ",")[1] or "wilderness"

    -- don't need to pick a home if we already have one
    if common.runtimeData.homes.byName[name] then return common.runtimeData.homes.byName[name] end

    -- check if the NPC already has a house
    for door in cell:iterateReferences(tes3.objectType.door) do
        if door.destination then
            local dest = door.destination.cell

            -- essentially, if npc full name, or surname matches the cell name
            if dest.id:match(name) or this.livesInManor(dest.name, name) then
                return dataTables.createHomedNPCTableEntry(npc, dest, cell, true)
            end
        end
    end

    -- haven't found a home, so put them in an inn or guildhall, or inside a canton
    if config.homelessWanderersToPublicHouses then
        log(common.logLevels.medium, "[HOUSING] Didn't find a home for %s, trying inns", npc.object.name)
        local dest = this.pickPublicHouseForNPC(npc, city)

        if dest then return dataTables.createHomedNPCTableEntry(npc, dest, cell, false) end

        -- if nothing was found, then we'll settle on Canton works cell, if the cell is a Canton
        if common.isCantonCell(cell) then
            if common.runtimeData.publicHouses[city] and
                common.runtimeData.publicHouses[city][common.publicHouseTypes.cantonworks] then
                local canton = table.choice(common.runtimeData.publicHouses[city][common.publicHouseTypes.cantonworks])
                log(common.logLevels.medium, "[HOUSING] Picking works %s, %s for %s", canton.city, canton.name, npc.object.name)

                if canton then return dataTables.createHomedNPCTableEntry(npc, canton.cell, cell, false) end
            end
        end
    end

    -- didn't find anything
    return nil
end

return this
