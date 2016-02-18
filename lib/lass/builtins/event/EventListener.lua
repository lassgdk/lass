local lass = require("lass")
local class = require("lass.class")

local EventListener = class.define(lass.Component, function(self, arguments)

	arguments.event = arguments.event or ""
	self.__base.init(self, arguments)
end)

function EventListener:awake()

	local listeners = self.globals.events[self.event].listeners

	-- # is the 'length' operator, and can be used to append a list
	listeners[#listeners + 1] = self
end

function EventListener:eventStart(source)

	if self.targetComponent and self.targetFunction then
		local component = self.gameObject:getComponent(self.targetComponent)

		-- call the specified method of the target component
		component[self.targetFunction](component, source)
	end
end

return EventListener