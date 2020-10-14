-- {{{ other files
-- todo: too many things require too many other things, needs fix
local config = require("celediel.NPCsGoHome.config").getConfig()
local common = require("celediel.NPCsGoHome.common")
local checks = require("celediel.NPCsGoHome.functions.checks")
local processors = require("celediel.NPCsGoHome.functions.processors")
local interop = require("celediel.NPCsGoHome.interop")
-- }}}

-- {{{ variables and such

-- for rebuilding follower list on dialogue
local followMatches = {"follow", "together", "travel", "wait", "stay"}

-- timers
local updateTimer
local postDialogueTimer

-- }}}

-- {{{ helper functions
local function log(level, ...) if config.logLevel >= level then common.log(...) end end
local function message(...) if config.showMessages then tes3.messageBox(...) end end

-- build a list of followers on cellChange
local function buildFollowerList()
    local f = {}
    -- build our followers list
    for friend in tes3.iterate(tes3.mobilePlayer.friendlyActors) do
        -- todo: check for ignored NPCs if followers list is ever used for anything other than part of checks.ignoredNPC()
        if friend ~= tes3.mobilePlayer then -- ? why is the player friendly towards the player ?
            f[friend.object.id] = true
            log(common.logLevels.large, "[MAIN] %s is follower", friend.object.id)
        end
    end
    return f
end

-- {{{ cell change checks

local function checkEnteredNPCHome(cell)
    local home = common.runtimeData.homes.byCell[cell.id]
    if home then
        local msg = string.format("Entering home of %s, %s", home.name, home.homeName)
        log(common.logLevels.small, "[MAIN] " .. msg)
        -- message(msg) -- this one is mostly for debugging, so it doesn't need to be shown
    end
end

local function checkEnteredPublicHouse(cell, city)
    local typeOfPub = common.pickPublicHouseType(cell)

    local publicHouse = common.runtimeData.publicHouses.byName[city] and
                            common.runtimeData.publicHouses.byName[city][cell.id]

    if publicHouse then
        local msg = string.format("Entering public space %s, a%s %s in the town of %s.", publicHouse.name,
                                  common.vowel(typeOfPub), typeOfPub:gsub("s$", ""), publicHouse.city)

        if publicHouse.proprietor then
            msg = msg ..
                      string.format(" Talk to %s, %s for services.", publicHouse.proprietor.object.name,
                                    publicHouse.proprietor.object.class)
        end

        log(common.logLevels.small, "[MAIN] " .. msg)
        message(msg) -- this one is more informative, and not entirely for debugging, and reminiscent of Daggerfall's messages
    end
end

-- }}}

local function applyChanges(cell)
    if not cell then cell = tes3.getPlayerCell() end

    if checks.isIgnoredCell(cell) then return end

    -- Interior cell, except Canton cells, don't do anything
    if checks.isInteriorCell(cell) and
        not (config.waistWorks == common.waist.exterior and common.isCantonWorksCell(cell)) then return end

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
    log(common.logLevels.medium, "[MAIN] Updating active cells!")

    common.runtimeData.followers = buildFollowerList()
    processors.searchCellsForPositions()

    for _, cell in pairs(tes3.getActiveCells()) do
        log(common.logLevels.large, "[MAIN] Applying changes to cell %s", cell.id)

        -- initialize runtime data if needed
        for _, t in pairs(common.runtimeData.NPCs) do t[cell.id] = t[cell.id] or {} end

        applyChanges(cell)
    end

    -- update interop runtime data after changes have been applied
    interop.setRuntimeData(common.runtimeData)
end

-- todo: more robust trespass checking... maybe take faction and rank into account?
-- todo: maybe re-implement some or all features of Trespasser
local function updatePlayerTrespass(cell, previousCell)
    cell = cell or tes3.getPlayerCell()

    local inCity = previousCell and (previousCell.id:match(cell.id) or cell.id:match(previousCell.id))

    if checks.isInteriorCell(cell) and not checks.isIgnoredCell(cell) and not checks.isPublicHouse(cell) and inCity then
        if checks.isNight() then
            tes3.player.data.NPCsGoHome.intruding = true
        else
            tes3.player.data.NPCsGoHome.intruding = false
        end
    else
        tes3.player.data.NPCsGoHome.intruding = false
    end
    log(common.logLevels.small, "[MAIN] Updating player trespass status to %s", tes3.player.data.NPCsGoHome.intruding)
end

-- }}}

-- {{{ event functions
local eventFunctions = {}

eventFunctions.onActivated = function(e)
    if e.activator ~= tes3.player or e.target.object.objectType ~= tes3.objectType.npc or not config.disableInteraction then
        return
    end

    local npc = e.target

    if tes3.player.data.NPCsGoHome.intruding and not checks.isIgnoredNPC(npc) then
        if npc.disposition and npc.disposition <= config.minimumTrespassDisposition then
            log(common.logLevels.medium, "[MAIN] Disabling dialogue with %s because trespass and disposition:%s",
                npc.object.name, npc.disposition)
            tes3.messageBox(string.format("%s: Get out before I call the guards!", npc.object.name))
            return false
        end
    end
end

eventFunctions.onLoaded = function()
    tes3.player.data.NPCsGoHome = tes3.player.data.NPCsGoHome or {}
    if tes3.player.cell then processors.searchCellsForNPCs() end

    common.runtimeData.followers = buildFollowerList()

    if not updateTimer or (updateTimer and updateTimer.state ~= timer.active) then
        updateTimer = timer.start({
            type = timer.simulate,
            duration = config.timerInterval,
            iterations = -1,
            callback = updateCells
        })
    end
end

eventFunctions.onCellChanged = function(e)
    updateCells()
    updatePlayerTrespass(e.cell, e.previousCell)
    checkEnteredNPCHome(e.cell)
    if e.cell.name then -- exterior wilderness cells don't have name
        checkEnteredPublicHouse(e.cell, common.split(e.cell.name, ",")[1])
    end
end

eventFunctions.onInfoResponse = function(e)
    -- the dialogue option clicked on
    local dialogue = tostring(e.dialogue):lower()
    -- what that dialogue option triggers; this will catch AIFollow commands
    local command = e.command:lower()

    for _, item in pairs(followMatches) do
        if command:match(item) or dialogue:match(item) then
            -- wait until game time restarts, and don't set multiple timers
            if not postDialogueTimer or postDialogueTimer.state ~= timer.active then
                log(common.logLevels.small, "Found %s in dialogue, rebuilding followers", item)
                postDialogueTimer = timer.start({
                    type = timer.simulate,
                    duration = 0.25,
                    iteration = 1,
                    callback = function() common.runtimeData.followers = buildFollowerList() end
                })
            end
        end
    end
end

-- debug events
eventFunctions.onKeyDown = function(e)
    if e.keyCode ~= tes3.scanCode.c then return end
    -- if alt log runtimeData
    if e.isAltDown then
        -- ! this crashes my fully modded setup and I dunno why
        -- ? doesn't crash my barely modded testing setup though
        -- log(common.logLevels.none, json.encode(common.runtimeData, { indent = true }))
        -- inspect handles userdata and tables within tables badly
        log(common.logLevels.none, common.inspect(common.runtimeData))
    end
    -- if ctrl log position data formatted for positions.lua
    if e.isControlDown then
        local pos = tostring(tes3.player.position):gsub("%(", "{"):gsub("%)", "}")
        local ori = tostring(tes3.player.orientation):gsub("%(", "{"):gsub("%)", "}")

        log(common.logLevels.none, "[POSITIONS] {position = %s, orientation = %s},", pos, ori)
    end
end

-- }}}

-- {{{ init
local function onInitialized()
    -- Register events
    log(common.logLevels.small, "[MAIN] Registering events...")
    for name, func in pairs(eventFunctions) do
        local eventName = name:gsub("on(%u)", string.lower)
        event.register(eventName, func)
        log(common.logLevels.small, "[MAIN] %s event registered", eventName)
    end

    log(common.logLevels.none, "Successfully initialized")
end

event.register("initialized", onInitialized)

-- MCM
event.register("modConfigReady", function() mwse.mcm.register(require("celediel.NPCsGoHome.mcm")) end)
-- }}}

-- vim:fdm=marker
