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

this.checkModdedCell = function(cellId)
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

this.createHomedNPCTableEntry = function(npc, home, startingPlace, isHome, position, orientation)
    if npc.object and (npc.object.name == nil or npc.object.name == "") then return end

    local pickedPosition, pickedOrientation, pos, ori

    -- mod support for different positions in cells
    local id = this.checkModdedCell(home.id)

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
    if not common.runtimeData.publicHouses[city][typeOfPub] then common.runtimeData.publicHouses[city][typeOfPub] = {} end

    common.runtimeData.publicHouses[city][typeOfPub][publicCell.id] = {
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
