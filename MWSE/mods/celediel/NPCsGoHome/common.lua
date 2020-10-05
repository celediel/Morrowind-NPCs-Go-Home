local this = {}

-- {{{ Variables and such
this.modName = "NPCs Go Home (At Night)"
this.author = "OEA/Celediel"
this.version = "0.0.1"
this.modInfo = "Move NPCs to their homes, or public houses (or just disable them), lock doors, " ..
                   "and prevent interaction after hours, selectively disable NPCs in inclement weather"
this.configPath = "NPCSGOHOME"
this.logString = this.modName:gsub("%s?%b()%s?","")

-- for config
this.logLevels = {none = 0, small = 1, medium = 2, large = 3}
this.waist = {neither = 0, exterior = 1, public = 2}

-- for runtime data
this.publicHouseTypes = {
    inns = "Inns",
    guildhalls = "Guildhalls",
    temples = "Temples",
    homes = "Homes",
    cantonworks = "Cantonworks"
}
-- }}}

-- {{{ Filled at runtime
this.runtimeData = {
    -- cells marked as public
    publicHouses = {
        -- used for caching public houses to avoid reiterating NPCs
        byName = {},
        -- used for picking cells to move NPCs to
        byType = {}
    },
    -- homes picked for NPCs
    homes = {
        -- used for caching homes to avoid reiterating NPCs
        byName = {},
        -- used for checking when entering wandering NPC's house, will probably remove
        byCell = {}
    },
    -- NPCs who have been moved
    movedNPCs = {},
    -- NPCs who stick around in bad weather and have been moved
    movedBadWeatherNPCs = {},
    -- NPCs who have been disabled
    disabledNPCs = {},
    -- NPCs who stick around in bad weather and have been disabled
    disabledBadWeatherNPCs = {},
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

this.log = function(...) mwse.log("[%s] %s", this.logString, string.format(...)) end

this.vowel = function(word)
    local s = string.sub(word, 1, 1)
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
    local id = cell.id:lower()
    if id:match("guild") then
        return this.publicHouseTypes.guildhalls
    elseif id:match("temple") then
        return this.publicHouseTypes.temples
    elseif id:match("canalworks") or cell.id:match("waistworks") then
        return this.publicHouseTypes.cantonworks
    elseif id:match("house") or id:match("manor") or id:match("tower") then
        return this.publicHouseTypes.homes
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
    local id = cell.id:lower()
    return id:match("waistworks") or id:match("canalworks") or id:match("underworks")
end

this.isCantonCell = function(cell)
    if cell.isInterior and not cell.behavesAsExterior then return false end
    for door in cell:iterateReferences(tes3.objectType.door) do
        if door.destination and this.isCantonWorksCell(door.destination.cell) then return true end
    end
    return false
end

this.isEmptyTable = function(t)
    for _ in pairs(t) do return false end
    return true
end
-- }}}

return this
