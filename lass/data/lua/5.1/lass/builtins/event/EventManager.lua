local lass = require("lass")
local class = require("lass.class")

local EventManager = class.define(lass.Component, function(self, arguments)

	arguments.events = arguments.events or {}
	lass.Component.init(self, arguments)
end)

function EventManager:awake()

	if not self.globals.events then
		self.globals.events = {}
	end

	for i, event in ipairs(self.events) do
		self:addEvent(event, false)
	end
end

function EventManager:addEvent(event, addToSelf)

	self.globals.events[event] = {
		listeners = {},

		trigger = function(self, component)
			for i, listener in ipairs(self.listeners) do
				listener:eventStart(component.gameObject)
			end
		end
	}

	if addToSelf or addToSelf == nil then
		self.events[#self.events + 1] = event
	end

end

return EventManager