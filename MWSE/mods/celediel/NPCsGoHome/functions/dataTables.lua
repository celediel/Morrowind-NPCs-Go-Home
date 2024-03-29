-- handles creation of runtime data tables
local common = require("celediel.NPCsGoHome.common")
local config = require("celediel.NPCsGoHome.config").getConfig()
local interop = require("celediel.NPCsGoHome.interop")
local positions = require("celediel.NPCsGoHome.data.positions")
local npcEvaluators = require("celediel.NPCsGoHome.functions.npcEvaluators")

local zeroVector = tes3vector3.new(0, 0, 0)
local function log(level, ...) if config.logLevel >= level then common.log(...) end end

local this = {}

this.createHomedNPCTableEntry = function(npc, home, startingPlace, isHome, position, orientation)
    if npc.object and (npc.object.name == nil or npc.object.name == "") then return end

    -- mod support for different positions in cells
    local id = common.checkModdedCell(home.id)

    log(common.logLevels.medium, "[DTAB] Found %s for %s from %s: %s... adding it to in memory table...",
        isHome and "home" or "public house", npc.object.name, startingPlace.id, id)

    -- pick the position and orientation the NPC will be placed at
    local pickedPosition, pickedOrientation, pos, ori

    if isHome and positions.npcs[npc.object.name] then
        pos = positions.npcs[npc.object.name].position
        ori = positions.npcs[npc.object.name].orientation
    elseif common.runtimeData.positions[id] and not table.empty(common.runtimeData.positions[id]) then
        -- pick a random position out of the positions in memory
        local choice, index = table.choice(common.runtimeData.positions[id])
        pos = choice.position
        ori = choice.orientation
        table.remove(common.runtimeData.positions[id], index)
    else
        pos = {0, 0, 0}
        ori = {0, 0, 0}
    end

    pickedPosition = tes3vector3.new(pos[1], pos[2], pos[3])
    pickedOrientation = tes3vector3.new(ori[1], ori[2], ori[3])

    log(common.logLevels.large, "[DTAB] Settled on position: %s, orientation: %s for %s in %s",
        pickedPosition,pickedOrientation, npc.object.name, id)

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
        ogPlaceName = startingPlace.id, -- string
        ogPosition = ogPosition, -- tes3vector3
        ogOrientation = ogOrientation, -- tes3vector3
        homePosition = pickedPosition, -- tes3vector3
        homeOrientation = pickedOrientation, -- tes3vector3
        worth = npcEvaluators.calculateNPCWorth(npc) -- int
    }

    common.runtimeData.homes.byName[npc.object.name] = entry
    if isHome then common.runtimeData.homes.byCell[home.id] = entry end

    interop.setRuntimeData(common.runtimeData)

    return entry
end

this.createPublicHouseTableEntry = function(publicCell, proprietor, city, name, cellWorth, cellFaction, type)
    local typeOfPub = type or common.pickPublicHouseType(publicCell) -- use shitty type picker if none specified

    local proprietorName = proprietor and proprietor.object.name or "no one"

    local data = {
        name = name,
        city = city,
        cell = publicCell,
        type = type,
        proprietor = proprietor,
        proprietorName = proprietorName,
        worth = cellWorth,
        faction = cellFaction
    }

    -- create by type
    if not common.runtimeData.publicHouses.byType[city] then common.runtimeData.publicHouses.byType[city] = {} end
    if not common.runtimeData.publicHouses.byType[city][typeOfPub] then common.runtimeData.publicHouses.byType[city][typeOfPub] = {} end
    common.runtimeData.publicHouses.byType[city][typeOfPub][publicCell.id] = data

    -- create by name
    if not common.runtimeData.publicHouses.byName[city] then common.runtimeData.publicHouses.byName[city] = {} end
    common.runtimeData.publicHouses.byName[city][publicCell.id] = data

    interop.setRuntimeData(common.runtimeData)
end

return this
