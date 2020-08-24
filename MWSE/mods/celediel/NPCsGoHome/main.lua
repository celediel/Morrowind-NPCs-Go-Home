-- {{{ other files
-- ? could probably split this file out to others as well
local config = require("celediel.NPCsGoHome.config").getConfig()
local common = require("celediel.NPCsGoHome.common")
local checks = require("celediel.NPCsGoHome.functions.checks")
local housing = require("celediel.NPCsGoHome.functions.housing")
local processors = require("celediel.NPCsGoHome.functions.processors")
-- }}}

-- {{{ variables and such

-- timers
local updateTimer

-- references to common.runtimeData
local publicHouses, homes, movedNPCs, followers

-- }}}

-- {{{ helper functions
local function log(level, ...) if config.logLevel >= level then common.log(...) end end
local function message(...) if config.showMessages then tes3.messageBox(...) end end

-- build a list of followers on cellChange
local function buildFollowerList()
    local f = {}
    -- build our followers list
    for friend in tes3.iterate(tes3.mobilePlayer.friendlyActors) do
        if friend ~= tes3.player then -- ? why is the player friendly towards the player ?
            f[friend.object.id] = true
            log(common.logLevels.large, "%s is follower", friend.object.id)
        end
    end
    return f
end

-- {{{ cell change checks

local function checkEnteredNPCHome(cell)
    local home = homes.byCell[cell.id]
    if home then
        local msg = string.format("Entering home of %s, %s", home.name, home.homeName)
        log(common.logLevels.small, msg)
        -- message(msg) -- this one is mostly for debugging, so it doesn't need to be shown
    end
end

local function checkEnteredPublicHouse(cell, city)
    local typeOfPub = common.pickPublicHouseType(cell)

    local publicHouse = publicHouses[city] and (publicHouses[city][typeOfPub] and publicHouses[city][typeOfPub][cell.name])

    if publicHouse then
        local msg = string.format("Entering public space %s, a%s %s in the town of %s.",
                                  publicHouse.name, common.vowel(typeOfPub), typeOfPub:gsub("s$", ""), publicHouse.city)

        if publicHouse.proprietor then
            msg = msg .. string.format(" Talk to %s, %s for services.", publicHouse.proprietor.object.name, publicHouse.proprietor.object.class)
        end

        log(common.logLevels.small, msg)
        message(msg) -- this one is more informative, and not entirely for debugging, and reminiscent of Daggerfall's messages
    end
end

-- }}}

local function applyChanges(cell)
    if not cell then cell = tes3.getPlayerCell() end

    if checks.isIgnoredCell(cell) then return end

    -- Interior cell, except Canton cells, don't do anything
    if checks.isInteriorCell(cell) and not (config.waistWorks == common.waist.exterior and checks.isCantonWorksCell(cell)) then
        return
    end

    -- don't do anything to public houses
    if checks.isPublicHouse(cell) then return end

    -- Deal with NPCs and mounts in cell
    processors.processNPCs(cell)
    processors.processPets(cell)
    processors.processSiltStriders(cell)

    -- check doors in cell, locking those that aren't inns/clubs
    processors.processDoors(cell)
end

local function updateCells()
    log(common.logLevels.medium, "Updating active cells!")

    followers = buildFollowerList()
    processors.searchCellsForPositions()

    for _, cell in pairs(tes3.getActiveCells()) do
        log(common.logLevels.large, "Applying changes to cell %s", cell.id)
        applyChanges(cell)
    end
end

local function updatePlayerTrespass(cell, previousCell)
    cell = cell or tes3.getPlayerCell()

    local inCity = previousCell and (previousCell.id:match(cell.id) or cell.id:match(previousCell.id))

    if checks.isInteriorCell(cell) and not checks.isIgnoredCell(cell) and not checks.isPublicHouse(cell) and inCity then
        if checks.checkTime() then
            tes3.player.data.NPCsGoHome.intruding = true
        else
            tes3.player.data.NPCsGoHome.intruding = false
        end
    else
        tes3.player.data.NPCsGoHome.intruding = false
    end
    log(common.logLevels.small, "Updating player trespass status to %s", tes3.player.data.NPCsGoHome.intruding)
end

-- }}}

-- {{{ event functions
local function onActivated(e)
    if e.activator ~= tes3.player or e.target.object.objectType ~= tes3.objectType.npc or not config.disableInteraction then
        return
    end

    if tes3.player.data.NPCsGoHome.intruding and not checks.isIgnoredNPC(e.target) then
        tes3.messageBox(string.format("%s: Get out before I call the guards!", e.target.object.name))
        return false
    end
end

local function onLoaded()
    tes3.player.data.NPCsGoHome = tes3.player.data.NPCsGoHome or {}
    -- tes3.player.data.NPCsGoHome.movedNPCs = tes3.player.data.NPCsGoHome.movedNPCs or {}
    -- movedNPCs = tes3.player.data.NPCsGoHome.movedNPCs or {}
    if tes3.player.cell then processors.searchCellsForNPCs() end

    followers = buildFollowerList()

    if not updateTimer or (updateTimer and updateTimer.state ~= timer.active) then
        updateTimer = timer.start({
            type = timer.simulate,
            duration = config.timerInterval,
            iterations = -1,
            callback = updateCells
        })
    end
end

local function onCellChanged(e)
    updateCells()
    followers = buildFollowerList()
    updatePlayerTrespass(e.cell, e.previousCell)
    checkEnteredNPCHome(e.cell)
    if e.cell.name then -- exterior wilderness cells don't have name
        checkEnteredPublicHouse(e.cell, common.split(e.cell.name, ",")[1])
    end
end
-- }}}

-- {{{ init
local function onInitialized()
    -- set up runtime data references
    publicHouses = common.runtimeData.publicHouses
    homes = common.runtimeData.homes
    movedNPCs = common.runtimeData.movedNPCs
    followers = common.runtimeData.followers

    -- Register events
    log(common.logLevels.small, "Registering events...")
    event.register("loaded", onLoaded)
    event.register("cellChanged", onCellChanged)
    event.register("activate", onActivated)

    log(common.logLevels.none, "Successfully initialized")
end

event.register("initialized", onInitialized)

-- MCM
event.register("modConfigReady", function() mwse.mcm.register(require("celediel.NPCsGoHome.mcm")) end)
-- }}}

-- vim:fdm=marker
