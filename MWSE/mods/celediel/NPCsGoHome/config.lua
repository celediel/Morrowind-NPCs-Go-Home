local common = require("celediel.NPCsGoHome.common")

-- todo: clean this up
local defaultConfig = {
    disableNPCs = true,
    lockDoors = true,
    disableInteraction = true,
    timerInterval = 7,
    ignored = {
        ["Balmora, Caius Cosades' House"] = true,
        ["Publican"] = true,
        -- ["Healer Service"] = true,
    },
    worstWeather = tes3.weather.thunder,
    keepBadWeatherNPCs = true,
    closeTime = 21,
    openTime = 7,
    minimumOccupancy = 3,
    waistWorks = true,
    moveNPCs = false,
    homelessWanderersToPublicHouses = false,
    logLevel = common.logLevels.none,
    factionIgnorePercentage = 0.67
}

local currentConfig

local this = {}

function this.getConfig()
    currentConfig = currentConfig or mwse.loadConfig(common.configPath, defaultConfig)
    return currentConfig
end

return this
