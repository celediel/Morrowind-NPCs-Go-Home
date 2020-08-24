-- handles creation of runtime data tables
local common = require("celediel.NPCsGoHome.common")
local interop = require("celediel.NPCsGoHome.interop")
local positions = require("celediel.NPCsGoHome.data.positions")
local config = require("celediel.NPCsGoHome.config").getConfig()

local zeroVector = tes3vector3.new(0, 0, 0)
local function log(level, ...) if config.logLevel >= level then common.log(...) end end

local this = {}

-- {{{ npc evaluators

-- NPCs barter gold + value of all inventory items
this.calculateNPCWorth = function(npc, merchantCell)
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

this.createHomedNPCTableEntry = function(npc, home, startingPlace, isHome, position, orientation)
    if npc.object and (npc.object.name == nil or npc.object.name == "") then return end

    local pickedPosition, pickedOrientation, pos, ori

    -- mod support for different positions in cells
    local id = common.checkModdedCell(home.id)

    log(common.logLevels.medium, "Found %s for %s: %s... adding it to in memory table...",
        isHome and "home" or "public house", npc.object.name, id)

    if isHome and positions.npcs[npc.object.name] then
        pos = positions.npcs[npc.object.name].position
        ori = positions.npcs[npc.object.name].orientation
    elseif common.runtimeData.positions[id] then
        local choice, index = table.choice(common.runtimeData.positions[id])
        pos = choice.position
        ori = choice.orientation
        table.remove(common.runtimeData.positions[id], index)
    else
        pos = {0, 0, 0}
        ori = {0, 0, 0}
    end

    log(common.logLevels.large, "Settled on position:%s, orientation:%s for %s in %s", pos, ori, npc.object.name, id)

    pickedPosition = tes3vector3.new(pos[1], pos[2], pos[3])
    pickedOrientation = tes3vector3.new(ori[1], ori[2], ori[3])

    local ogPosition = position and (tes3vector3.new(position.x, position.y, position.z)) or
                           (npc.position and npc.position:copy() or zeroVector:copy())

    local ogOrientation = orientation and (tes3vector3.new(orientation.x, orientation.y, orientation.z)) or
                              (npc.orientation and npc.orientation:copy() or zeroVector:copy())

    local entry = {
        name = npc.object.name, -- string
        npc = npc, -- tes3npc
        isHome = isHome, -- bool
        home = home, -- tes3cell
        homeName = home.id, -- string
        ogPlace = startingPlace, -- tes3cell
        ogPlaceName = startingPlace.id,
        ogPosition = ogPosition, -- tes3vector3
        ogOrientation = ogOrientation, -- tes3vector3
        homePosition = pickedPosition, -- tes3vector3
        homeOrientation = pickedOrientation, -- tes3vector3
        worth = this.calculateNPCWorth(npc) -- int
    }

    common.runtimeData.homes.byName[npc.object.name] = entry
    if isHome then common.runtimeData.homes.byCell[home.id] = entry end

    interop.setRuntimeData(common.runtimeData)

    return entry
end

this.createPublicHouseTableEntry = function(publicCell, proprietor, city, name)
    local typeOfPub = common.pickPublicHouseType(publicCell)

    local worth = 0

    -- cell worth is combined worth of all NPCs
    for innard in publicCell:iterateReferences(tes3.objectType.npc) do
        if innard == proprietor then
            worth = worth + this.calculateNPCWorth(innard, publicCell)
        else
            worth = worth + this.calculateNPCWorth(innard)
        end
    end

    local proprietorName = proprietor and proprietor.object.name or "no one"

    if not common.runtimeData.publicHouses[city] then common.runtimeData.publicHouses[city] = {} end
    if not common.runtimeData.publicHouses[city][typeOfPub] then
        common.runtimeData.publicHouses[city][typeOfPub] = {}
    end

    common.runtimeData.publicHouses[city][typeOfPub][publicCell.id] =
        {
            name = name,
            city = city,
            cell = publicCell,
            proprietor = proprietor,
            proprietorName = proprietorName,
            worth = worth
        }

    interop.setRuntimeData(common.runtimeData)
end

return this
