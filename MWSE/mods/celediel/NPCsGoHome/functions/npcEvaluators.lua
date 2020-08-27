-- handles evaluating NPCs
local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()

local this = {}

-- todo: logging
local function log(level, ...) if config.logLevel >= level then common.log(...) end end

-- NPCs barter gold + value of all inventory items
this.calculateNPCWorth = function(npc, merchantCell)
    -- start with this
    local worth = {barter = npc.object.barterGold, equipment = 0, inventory = 0}

    -- add currently equipped items
    if npc.object.equipment then
        for _, item in pairs(npc.object.equipment) do
            worth.equipment = worth.equipment + (item.object.value or 0)
        end
    end

    -- add items in inventory
    if npc.object.inventory then
        for _, item in pairs(npc.object.inventory) do
            worth.inventory = worth.inventory + (item.object.value or 0)
        end
    end

    -- calculate value of objects sold by NPC in the cell, and add it to barter
    if merchantCell then -- if we pass a cell argument
        for box in merchantCell:iterateReferences(tes3.objectType.container) do -- loop over each container
            if box.inventory then -- if it's not empty
                for item in tes3.iterate(box.inventory) do -- loop over its items
                    if npc.object:tradesItemType(item.objectType) then -- if the NPC sells that type
                        worth.barter = worth.barter + item.object.value -- add its value to the NPCs total value
                    end
                end
            end
        end
    end

    -- calculate the total
    local total = 0
    for _, v in pairs(worth) do total = total + v end
    log(common.logLevels.medium, "Calculated worth of %s for %s", total, npc.object.name)

    -- then add it to the table
    worth.total = total

    return worth
end

return this
