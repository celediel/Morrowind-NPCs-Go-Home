local this = {}

local homedNPCs = {}

this.setHomedNPCTable = function(t) homedNPCs = t end

this.getHomedNPCTable = function() return homedNPCs end

local inns = {}

this.setInnTable = function(t) inns = t end

this.getInnTable = function() return inns end

local movedNPCs = {}

this.setMovedNPCsTable = function(t) movedNPCs = t end

this.getMovedNPCsTable = function() return movedNPCs end

return this
