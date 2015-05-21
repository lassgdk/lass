local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

local EventTrigger = class.define(lass.Component, function(self, arguments)

	arguments.events = arguments.events or {}
	self.base.init(self, arguments)
end)