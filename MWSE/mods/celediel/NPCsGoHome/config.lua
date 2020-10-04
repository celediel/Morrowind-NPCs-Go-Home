local common = require("celediel.NPCsGoHome.common")

-- todo: clean this up some more
local defaultConfig = {
    -- general settings
    ignored = {
        ["Balmora, Caius Cosades' House"] = true,
        ["Publican"] = true -- inns are public
    },
    closeTime = 21,
    openTime = 7,
    timerInterval = 7,
    showMessages = true,
    -- npc settings
    disableNPCs = true,
    moveNPCs = true, -- move NPCs to homes
    keepBadWeatherNPCs = true,
    -- classes and races that are ignored during inclement weather
    badWeatherClassRace = {
        ["argonian"] = true,
        ["t_pya_seaelf"] = true,
        ["pilgrim"] = true,
        ["t_cyr_pilgrim"] = true,
        ["t_sky_pilgrim"] = true
    },
    worstWeather = tes3.weather.thunder,
    factionIgnorePercentage = 66,
    minimumOccupancy = 4,
    homelessWanderersToPublicHouses = false, -- move NPCs to public houses if they don't have a home
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
