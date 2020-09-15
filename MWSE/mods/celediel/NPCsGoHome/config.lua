local common = require("celediel.NPCsGoHome.common")

-- todo: clean this up
local defaultConfig = {
    -- general settings
    ignored = {
        ["Balmora, Caius Cosades' House"] = true,
        ["Publican"] = true, -- inns are public
    },
    closeTime = 21,
    openTime = 7,
    timerInterval = 7,
    showMessages = true,
    -- npc settings
    disableNPCs = true,
    moveNPCs = true,
    keepBadWeatherNPCs = true,
    worstWeather = tes3.weather.thunder,
    factionIgnorePercentage = 66,
    minimumOccupancy = 3,
    homelessWanderersToPublicHouses = false,
    disableInteraction = true,
    -- door settings
    lockDoors = true,
    waistWorks = common.waist.interior,
    -- debug settings
    logLevel = common.logLevels.none
}

local currentConfig

local this = {}

function this.getConfig()
    currentConfig = currentConfig or mwse.loadConfig(common.configPath, defaultConfig)
    return currentConfig
end

return this
