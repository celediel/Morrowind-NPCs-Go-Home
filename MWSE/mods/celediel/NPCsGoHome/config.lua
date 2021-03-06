local common = require("celediel.NPCsGoHome.common")

-- todo: clean this up some more
local defaultConfig = {
    -- general settings
    ignored = {
        ["balmora, caius cosades' house"] = true,
        ["publican"] = true, -- inns are public
        ["abotwhereareallbirdsgoing.esp"] = true, -- ignore abot's creature mods by default
        ["abotwaterlife.esm"] = true,
    },
    closeTime = 21,
    openTime = 7,
    timerInterval = 7,
    showMessages = true,
    -- npc settings
    disableNPCs = true,
    disableNPCsInWilderness = false,
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
    minimumTrespassDisposition = 50, -- if player's disposition with NPC is less than this value, interaction is disabled
    -- door settings
    lockDoors = true,
    cantonCells = common.canton.interior,
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
