local class = require("lass.class")

local DelayObject = class.define(self, function(self, func, ...)

	self.func = func
	self.args = table.pack(...)
end)

function DelayObject:__call()

	local r = self.func(unpack(self.args))
	-- print(r)
	return r
end

return DelayObject
