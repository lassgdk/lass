local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.collision.Collider")

--[[
CircleCollider
]]

local CircleCollider = class.define(Collider, function(self, arguments)

	if not arguments.shapeSource then
		arguments.shape = geometry.Circle(arguments.radius, arguments.center)
	else
		--placeholder until shapeSource exists
		arguments.shape = geometry.Circle(0)
	end

	arguments.radius, arguments.center = nil, nil

	self.base.init(self, arguments)
end)

-- function CircleCollider:awake()

-- 	if self.shapeSource then
-- 		self.shapeSource = self.gameObject:getComponent(self.shapeSource)
-- 		self.shape = self.shapeSource.shape
-- 	end

-- 	self.base.awake(self)
-- end

return CircleCollider