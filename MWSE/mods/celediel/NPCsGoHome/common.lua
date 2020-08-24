local inspect = require("inspect")

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
this.publicHouseTypes = {inns = "Inns", guildhalls = "Guildhalls", temples = "Temples", houses = "Houses", cantonworks = "Cantonworks"}
-- }}}

-- {{{ Filled at runtime
this.runtimeData = {
    -- cells marked as public
    publicHouses = {},
    -- homes picked for NPCs
    homes = {
        byName = {},
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

this.inspect = function(thing)
    this.log("Inspecting a %s", thing)
    this.log(inspect(thing))
end

this.vowel = function(str)
    local s = string.sub(str, 1, 1)
    local n = ""

    if string.match(s, "[AOEUIaoeui]") then n = "n" end

    return n
end

-- todo: pick this better
this.pickPublicHouseType = function(cell)
    if cell.id:match("Guild") then
        return this.publicHouseTypes.guildhalls
    elseif cell.id:match("Temple") then
        return this.publicHouseTypes.temples
    elseif cell.id:match("[Cc]analworks") or cell.id:match("[Ww]aistworks") then
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
-- }}}

return this
