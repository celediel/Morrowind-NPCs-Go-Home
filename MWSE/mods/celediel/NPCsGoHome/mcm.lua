local config = require("celediel.NPCsGoHome.config").getConfig()
local common = require("celediel.NPCsGoHome.common")

local function createTableVar(id) return mwse.mcm.createTableVariable({id = id, table = config}) end

-- LinQ could do this in one line lol
local function allTheThings(thingType, useKey)
    local things = {}
    for key, value in pairs(thingType) do
        table.insert(things, string.lower(useKey and (key.id or key) or (value.id or value)))
    end
    return things
end

local template = mwse.mcm.createTemplate({name = common.modName})
template:saveOnClose(common.configPath, config)

local page = template:createSideBarPage({
    label = "Main Options",
    description = string.format("%s v%s by %s\n\n%s\n\n", common.modName, common.version, common.author, common.modInfo)
})

-- todo: categorize the options
local category = page:createCategory(common.modName)

category:createDropdown({
    label = "Debug log level",
    description = "Enable this if you want to flood mwse.log with nonsense. Even small is huge." ..
        "Large in Old Ebonheart spits out 16k lines each update. Don't pick that option.",
    options = {
        {label = "None", value = common.logLevels.none},
        {label = "Small", value = common.logLevels.small},
        {label = "Medium", value = common.logLevels.medium},
        {label = "Large", value = common.logLevels.large}
    },
    variable = createTableVar("logLevel")
})

category:createYesNoButton({label = "Lock doors and containers at night?", variable = createTableVar("lockDoors")})

category:createYesNoButton({label = "Disable non-Guard NPCs at night?", variable = createTableVar("disableNPCs")})

category:createYesNoButton({
    label = "Move NPCs into their homes at night and in bad weather instead of disabling them?",
    variable = createTableVar("moveNPCs")
})

category:createYesNoButton({
    label = "Move \"homeless\" NPCs to public spaces at night and in bad weather instead of disabling them?",
    variable = createTableVar("homelessWanderersToPublicHouses")
})

category:createYesNoButton({
    label = "Prevent dialogue in interiors at night?",
    variable = createTableVar("disableInteraction")
})

category:createDropdown({
    label = "Treat Canton waistworks as exteriors, public spaces, or neither",
    description = "If canton cells are treated as exterior, inside NPCs will be disabled, and doors will be locked.\n" ..
        "If they're treated as public spaces, inside NPCs won't be disabled, and homeless NPCs will be moved inside " ..
        "(if configured to do so).\n\nIf neither, canton cells will be treated as any other.",
    options = {
        {label = "Neither", value = common.waist.neither},
        {label = "Exterior", value = common.waist.exterior},
        {label = "Public", value = common.waist.public}
    },
    defaultSetting = common.waist.neither,
    variable = createTableVar("waistWorks")
})

category:createYesNoButton({
    label = "Keep Caravaners, their Silt Striders, and Argonians enabled in inclement weather?",
    variable = createTableVar("keepBadWeatherNPCs")
})

category:createDropdown({
    label = "NPC Inclement Weather Cutoff Point",
    description = "NPCs \"go home\" in this weather or worse",
    options = {
        {label = "None", value = 10},
        {label = "Clear", value = tes3.weather.clear},
        {label = "Cloudy", value = tes3.weather.cloudy},
        {label = "Foggy", value = tes3.weather.foggy},
        {label = "Overcast", value = tes3.weather.overcast},
        {label = "Rain", value = tes3.weather.rain},
        {label = "Thunderstorm", value = tes3.weather.thunder},
        {label = "Ashstorm", value = tes3.weather.ash},
        {label = "Blight", value = tes3.weather.blight},
        {label = "Snow", value = tes3.weather.snow},
        {label = "Blizzard", value = tes3.weather.blizzard}
    },
    defaultSetting = tes3.weather.thunder,
    variable = createTableVar("worstWeather")
})

category:createSlider({
    label = "Close Time",
    description = "Time when people go home and doors lock",
    min = 0,
    max = 24,
    step = 1,
    jump = 2,
    variable = createTableVar("closeTime")
})

category:createSlider({
    label = "Open Time",
    description = "Time when people wake up and doors unlock",
    min = 0,
    max = 24,
    step = 1,
    jump = 2,
    variable = createTableVar("openTime")
})

category:createSlider({
    label = "Minimum number of occupants for public house",
    description = "Cells with less than this number of occupants won't even be considered for \"public house\" status.\n\n" ..
        "Blades (if on the ignore list) are an exception to this rule, because Blades trainers don't mind if you come in.",
    min = 1,
    max = 20,
    step = 1,
    jump = 4,
    variable = createTableVar("minimumOccupancy")
})

category:createSlider({
    label = "Faction Ignore Percentage",
    description = "Cells whose occupants are this % or more of one faction will be marked public if that faction is on the ignored list.",
    min = 0,
    max = 100,
    step = 5,
    jump = 10,
    variable = createTableVar("factionIgnorePercentage")
})

category:createSlider({
    label = "Update Timer",
    description = [[How often the update timer fires, in seconds. Updates are also triggered on cell change.]],
    min = 1,
    max = 60,
    step = 1,
    jump = 2,
    -- todo: button or something to reset the timer to the new interval
    restartRequired = true,
    variable = createTableVar("timerInterval")
})

category:createYesNoButton({
    label = "Show messages when entering public spaces/NPC homes",
    variable = createTableVar("showMessages")
})

template:createExclusionsPage({
    label = "Ignored things",
    description = ("NPCs on the Ignored list will not disappear at night, and will be available to talk to if indoors. " ..
        "Interior Cells on the Ignored list will not have the doors to them locked. Exterior cells will have neither doors nor NPCs in them affected. " ..
        "Many exterior cells have the same name, and so you will need to use trial and error to disable the correct ones. " ..
        "For Plugins, all the above applies to all applicable data from the mod. " ..
        "For classes any cell that contains at least one NPC of said class will be considered \"public\", " ..
        "and will not be locked or have its NPCS disabled at night. Exterior NPCs of this class or faction will not be disabled. " ..
        "For factions, at least 75% of the cell's occupants need to be a part of said faction." ..
        "Best used with Guilds and Publican classes."),
    showAllBlocked = false,
    variable = createTableVar("ignored"),

    filters = {
        {label = "Plugins", type = "Plugin"},
        {label = "NPCs", type = "Object", objectType = tes3.objectType.npc},
        {label = "Cells", callback = function() return allTheThings(tes3.dataHandler.nonDynamicData.cells, true) end},
        {label = "Factions", callback = function() return allTheThings(tes3.dataHandler.nonDynamicData.factions) end},
        {label = "Classes", callback = function() return allTheThings(tes3.dataHandler.nonDynamicData.classes) end}
    }
})

return template
