local this = {}

-- {{{ Variables and such
this.modName = "NPCs Go Home (At Night)"
this.author = "OEA/Celediel"
this.version = "0.0.1"
this.modInfo = "Move NPCs to their homes, or public houses (or just disable them), lock doors, " ..
                   "and prevent interaction after hours, selectively disable NPCs in inclement weather"
this.configPath = "NPCSGOHOME"

-- for config
this.logLevels = {none = 0, small = 1, medium = 2, large = 3}
this.waist = {neither = 0, exterior = 1, public = 2}

-- for runtime data
this.publicHouseTypes = {
    inns = "Inns",
    guildhalls = "Guildhalls",
    temples = "Temples",
    houses = "Houses",
    cantonworks = "Cantonworks"
}

-- Canton string matches
-- move NPCs into waistworks
this.waistworks = "[Ww]aistworks"
-- don't lock canalworks
this.canalworks = "[Cc]analworks"
-- doors to underworks should be ignored
-- but NPCs in underworks should not be disabled
this.underworks = "[Uu]nderworks"

-- }}}

-- {{{ Filled at runtime
this.runtimeData = {
    -- cells marked as public
    publicHouses = {},
    -- homes picked for NPCs
    homes = {
        -- used for caching homes to avoid reiterating NPCs
        byName = {},
        -- used for checking when entering wandering NPC's house, will probably remove
        byCell = {}
    },
    -- NPCs who have been moved
    movedNPCs = {},
    -- positions that haven't been used
    positions = {},
    -- player companions
    followers = {}
}
-- }}}

-- {{{ Functions
this.split = function(input, sep)
    if not input then return end
    if not sep then sep = "%s" end
    local output = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do table.insert(output, str) end
    return output
end

this.log = function(...) mwse.log("[%s] %s", this.modName, string.format(...)) end

this.vowel = function(str)
    local s = string.sub(str, 1, 1)
    local n = ""

    if string.match(s, "[AOEUIaoeui]") then n = "n" end

    return n
end

-- picks the key of the largest value out of a key:whatever, value:number table
this.keyOfLargestValue = function(t)
    local picked
    local largest = 0
    for key, value in pairs(t) do
        if value > largest then
            largest = value
            picked = key
        end
    end
    return picked
end

-- todo: pick this better
this.pickPublicHouseType = function(cell)
    if cell.id:match("Guild") then
        return this.publicHouseTypes.guildhalls
    elseif cell.id:match("Temple") then
        return this.publicHouseTypes.temples
    elseif cell.id:match(this.canalworks) or cell.id:match(this.waistworks) then
        return this.publicHouseTypes.cantonworks
    -- elseif cell.id:match("House") then
    --     return publicHouseTypes.houses
    else
        return this.publicHouseTypes.inns
    end
end

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

this.isCantonWorksCell = function(cell)
    -- for _, str in pairs(waistworks) do if cell.id:match(str) then return true end end
    return cell.id:match(this.waistworks) or cell.id:match(this.canalworks) or cell.id:match(this.underworks)
end

this.isCantonCell = function(cell)
    if cell.isInterior and not cell.behavesAsExterior then return false end
    for door in cell:iterateReferences(tes3.objectType.door) do
        if door.destination and this.isCantonWorksCell(door.destination.cell) then return true end
    end
    return false
end
-- }}}

return this
