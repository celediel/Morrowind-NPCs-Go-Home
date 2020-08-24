local this = {}

-- access to runtime data
local runtimeData = {}
this.setRuntimeData = function(t) runtimeData = t end
this.getRuntimeData = function() return runtimeData end

return this
