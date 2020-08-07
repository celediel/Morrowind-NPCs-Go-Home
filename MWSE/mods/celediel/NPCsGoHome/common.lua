local inspect = require("inspect")

local this = {}

this.modName = "NPCs Go Home (At Night)"
this.author = "OEA/Celediel"
this.version = "0.0.1"
this.modInfo = "Move NPCs to their homes, or public houses (or just disable them), lock doors, " ..
                   "and prevent interaction after hours, selectively disable NPCs in inclement weather"
this.configPath = "NPCSGOHOME"

this.logLevels = {none = 0, small = 1, medium = 2, large = 3}

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

return this
