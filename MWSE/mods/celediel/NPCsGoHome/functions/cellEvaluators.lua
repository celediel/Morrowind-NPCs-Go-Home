local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local npcEvaluators = require("celediel.NPCsGoHome.functions.npcEvaluators")

local this = {}

local function log(level, ...) if config.logLevel >= level then common.log(...) end end

-- cellEvaluators can't require checks because checks already requires cellEvaluators
-- this means I have too much spaghetti
local function isIgnoredNPCLite(npc)
    local obj = npc.baseObject and npc.baseObject or npc.object

    local isGuard = obj.isGuard or (obj.name and (obj.name:lower():match("guard") and true or false) or false) -- maybe this should just be an if else
    local isVampire = obj.head and (obj.head.vampiric and true or false) or false

    return config.ignored[obj.id:lower()] or
           config.ignored[obj.sourceMod:lower()] or
           isGuard or
           isVampire
end

-- cell worth is combined worth of all NPCs
this.calculateCellWorth = function(cell, proprietor)
    local worth = 0

    local msg = "breakdown:\n"
    for innard in cell:iterateReferences(tes3.objectType.npc) do
        if not isIgnoredNPCLite(innard) then
            local total = npcEvaluators.calculateNPCWorth(innard, innard == proprietor and cell or nil).total
            worth = worth + total
            msg = msg .. string.format("%s worth:%s, ", innard.object.name, total)
        end
    end

    log(common.logLevels.medium, "[CELLEVAL] Calculated worth of %s for cell %s", worth, cell.id)
    log(common.logLevels.large, "[CELLEVAL] " .. msg:sub(1, #msg - 2)) -- strip off last ", "
    return worth
end

-- iterate NPCs in the cell, if configured amount of the population is any one
-- faction, that's the cell's faction, otherwise, cell doesn't have a faction.
this.pickCellFaction = function(cell)
    local npcs = {majorityFactions = {}, allFactions = {}, total = 0}

    -- count all the npcs with factions
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        if not isIgnoredNPCLite(npc) then
            local faction = npc.object.faction

            if faction then
                if not npcs.allFactions[faction.id] then npcs.allFactions[faction.id] = {total = 0, percentage = 0} end

                if not npcs.allFactions[faction.id].master or npcs.allFactions[faction.id].master.object.factionIndex <
                    npc.object.factionIndex then npcs.allFactions[faction.id].master = npc end

                npcs.allFactions[faction.id].total = npcs.allFactions[faction.id].total + 1
            end

            npcs.total = npcs.total + 1
        end
    end

    -- pick out all the factions that make up a percentage of the cell greater than the configured value
    -- as long as the cell passes the minimum requirement check
    for id, info in pairs(npcs.allFactions) do
        info.percentage = (info.total / npcs.total) * 100
        if info.percentage >= config.factionIgnorePercentage and npcs.total >= config.minimumOccupancy then
            npcs.majorityFactions[id] = info.percentage
        end
    end

    -- from the majority values, return the faction with the largest percentage, or nil
    local picked = common.keyOfLargestValue(npcs.majorityFactions)
    log(common.logLevels.medium, "[CELLEVAL] Picked faction %s for cell %s", picked, cell.id)
    log(common.logLevels.large, "[CELLEVAL] breakdown:\n%s", json.encode(npcs, {indent = true}))
    return picked
end

return this
