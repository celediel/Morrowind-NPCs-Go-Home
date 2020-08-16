local this = {}

-- access to the NPCs that have homes or have been assigned a public house
local homedNPCs = {}
this.setHomedNPCTable = function(t) homedNPCs = t end
this.getHomedNPCTable = function() return homedNPCs end

-- access to any cells that have been marked public
local pubs = {}
this.setPublicHouseTable = function(t) pubs = t end
this.getPublicHouseTable = function() return pubs end

-- access to NPCs that have been moved
local moved = {}
this.setMovedNPCTable = function(t) moved = t end
this.getMovedNPCTable = function() return moved end

return this
