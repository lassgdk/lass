local lass = require("lass")
local class = require("lass.class")

local {{componentName}} = class.define(lass.Component, function(self, arguments)

	-- super constructor--component will not be created properly if next line is removed
	self.base.init(self)
end)

return {{componentName}}