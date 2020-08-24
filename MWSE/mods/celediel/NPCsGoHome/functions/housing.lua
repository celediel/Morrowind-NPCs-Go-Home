local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local interop = require("celediel.NPCsGoHome.interop")
local positions = require("celediel.NPCsGoHome.data.positions")

local function log(level, ...) if config.logLevel >= level then common.log(...) end end

local publicHouseTypes = {inns = "Inns", guildhalls = "Guildhalls", temples = "Temples", houses = "Houses"}

-- animated morrowind NPCs are contextual
local contextualNPCs = {"^AM_"}

local this = {}

this.zeroVector = tes3vector3.new(0, 0, 0)

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

-- todo: pick this better
this.pickPublicHouseType = function(cell)
    if cell.id:match("Guild") then
        return publicHouseTypes.guildhalls
    elseif cell.id:match("Temple") then
        return publicHouseTypes.temples
    -- elseif cell.id:match("House") then
    --     return publicHouseTypes.houses
    else
        return publicHouseTypes.inns
    end
end

-- ? I honestly don't know if there are any wandering NPCs that "live" in close-by manors, but I wrote this anyway
this.livesInManor = function(cellName, npcName)
    if not cellName or (cellName and not string.find(cellName, "Manor")) then return end

    local splitName = common.split(npcName)
    local given = splitName[1]
    local sur = splitName[2]

    -- surnameless peasants don't live in manors
    if not sur then return end

    log(common.logLevels.large, "Checking if %s %s lives in %s", given, sur, cellName)
    return string.match(cellName, sur)
end

this.pickInnForNPC = function(npc, city)
    -- todo: pick in Inn intelligently ?
    -- high class inns for nobles and rich merchants and such
    -- lower class inns for middle class npcs and merchants
    -- temple for commoners and the poorest people
    -- ? pick based on barterGold and value of equipment for merchants ?
    -- ? for others, pick based on value of equipment

    -- but for now pick one at random
    if common.runtimeData.publicHouses[city] and common.runtimeData.publicHouses[city][publicHouseTypes.inns] then
        local choice = table.choice(common.runtimeData.publicHouses[city][publicHouseTypes.inns])
        if not choice then return end
        log(common.logLevels.medium, "Picking inn %s, %s for %s", choice.city, choice.name, npc.object.name)
        return choice.cell
    end
end

this.pickPublicHouseForNPC = function(npc, city)
    -- look for wandering guild members
    if common.runtimeData.publicHouses[city] and common.runtimeData.publicHouses[city][publicHouseTypes.guildhalls] then
        for _, data in pairs(common.runtimeData.publicHouses[city][publicHouseTypes.guildhalls]) do
            -- if npc's faction and proprietor's faction match, pick that one
            if npc.object.faction == data.proprietor.object.faction then
                log(common.logLevels.medium, "Picking %s for %s based on faction", data.cell.id, npc.object.name)
                return data.cell
            end
        end
    end

    -- temple members go to the temple
    if common.runtimeData.publicHouses[city] and common.runtimeData.publicHouses[city][publicHouseTypes.temples] then
        for _, data in pairs(common.runtimeData.publicHouses[city][publicHouseTypes.temples]) do
            if npc.object.faction == data.proprietor.object.faction then
                log(common.logLevels.medium, "Picking temple %s for %s based on faction", data.cell.id, npc.object.name)
                return data.cell
            end
        end
    end

    -- found nothing so pick an inn
    return this.pickInnForNPC(npc, city)
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

    local this = {
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

    common.runtimeData.homes.byName[npc.object.name] = this
    if isHome then common.runtimeData.homes.byCell[home.id] = this end

    interop.setHomedNPCTable(common.runtimeData.homes.byName)

    return this
end

this.createPublicHouseTableEntry = function(publicCell, proprietor, city, name)
    local typeOfPub = this.pickPublicHouseType(publicCell)

    local worth = 0

    -- for houses, worth is equal to NPC who lives there
    -- if typeOfPub == publicHouseTypes.houses then
    --     worth = calculateNPCWorth(proprietor)
    -- else
        -- for other types, worth is combined worth of all NPCs
        for innard in publicCell:iterateReferences(tes3.objectType.npc) do
            if innard == proprietor then
                worth = worth + this.calculateNPCWorth(innard, publicCell)
            else
                worth = worth + this.calculateNPCWorth(innard)
            end
        end
    -- end

    if not common.runtimeData.publicHouses[city] then common.runtimeData.publicHouses[city] = {} end
    if not common.runtimeData.publicHouses[city][typeOfPub] then common.runtimeData.publicHouses[city][typeOfPub] = {} end

    common.runtimeData.publicHouses[city][typeOfPub][publicCell.id] = {
        name = name,
        city = city,
        cell = publicCell,
        proprietor = proprietor,
        proprietorName = proprietor.object.name,
        worth = worth
    }

    interop.setPublicHouseTable(common.runtimeData.publicHouses)
end

-- looks through doors to find a cell that matches a wandering NPCs name
this.pickHomeForNPC = function(cell, npc)
    -- wilderness cells don't have name
    if not cell.name then return end

    -- don't move contextual, such as Animated Morrowind, NPCs at all
    for _, str in pairs(contextualNPCs) do if npc.object.id:match(str) then return end end

    local name = npc.object.name
    local city = common.split(cell.name, ",")[1]
    for door in cell:iterateReferences(tes3.objectType.door) do
        if door.destination then
            local dest = door.destination.cell

            -- essentially, if npc full name, or surname matches the cell name
            if dest.id:match(name) or this.livesInManor(dest.name, name) then
                if common.runtimeData.homes.byName[name] then -- already have a home, don't create the table entry again
                    return common.runtimeData.homes.byName[name]
                else
                    return this.createHomedNPCTableEntry(npc, dest, cell, true)
                end
            end
        end
    end

    -- haven't found a home, so put them in an inn or guildhall
    if config.homelessWanderersToPublicHouses then
        log(common.logLevels.medium, "Didn't find a home for %s, trying inns", npc.object.name)
        local dest = this.pickPublicHouseForNPC(npc, city)
        -- return createHomedNPCTableEntry(npc, dest, door)
        if dest then return this.createHomedNPCTableEntry(npc, dest, cell, false) end
    end

    return nil
end

return this
