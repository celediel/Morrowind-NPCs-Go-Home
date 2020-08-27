local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local npcEvaluators = require("celediel.NPCsGoHome.functions.npcEvaluators")

local this = {}

-- todo: logging
local function log(level, ...) if config.logLevel >= level then common.log(...) end end

this.calculateCellWorth = function(cell, proprietor)
    -- cell worth is combined worth of all NPCs
    local worth = 0

    for innard in cell:iterateReferences(tes3.objectType.npc) do
        worth = worth + npcEvaluators.calculateNPCWorth(innard, innard == proprietor and cell or nil).total
    end

    return worth
end

this.pickCellFaction = function(cell)
    -- iterate NPCs in the cell, if 2/3 the population is any one faction,
    -- that's the cell's faction, otherwise, cell doesn't have a faction.
    local npcs = {majorityFactions = {}, allFactions = {}, total = 0}
    for npc in cell:iterateReferences(tes3.objectType.npc) do
        local faction = npc.object.faction

        if faction then
            if not npcs.allFactions[faction] then npcs.allFactions[faction] = {total = 0, percentage = 0} end

            if not npcs.allFactions[faction].master or npcs.allFactions[faction].master.object.factionIndex <
                npc.object.factionIndex then npcs.allFactions[faction].master = npc end

            npcs.allFactions[faction].total = npcs.allFactions[faction].total + 1
        end

        npcs.total = npcs.total + 1
    end

    for faction, info in pairs(npcs.allFactions) do
        info.percentage = (info.total / npcs.total) * 100
        if info.percentage >= config.factionIgnorePercentage then
            -- return faction.id
            npcs.majorityFactions[faction] = info.percentage
        end
    end

    -- no faction
    return table.empty(npcs.majorityFactions) and "none" or common.keyOfLargestValue(npcs.majorityFactions)
end

return this
