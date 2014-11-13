local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

--[[
Collider - base class for all collider components
do not use this as a component directly! (unless you can think of a good reason)
]]

local Collider = class.define(lass.Component, function(self, properties)
	-- assert(class.instanceof(properties.shape, geometry.Shape), "shape must be geometry.Shape")

	for k,v in pairs(self.base) do
		print(k,v)
	end
	print("=====", self.base == lass.Component)
	self.base.init(self, properties)
end)

function Collider:isCollidingWith(other)

	local otherType = class.instanceof(Collider, geometry.Shape, geometry.Vector2)
	assert(otherType, "other must be a Collider, Shape, or Vector2")
	if otherType == Collider then
		return geometry.intersecting(
			self.shape, other.shape, self.gameObject.globalTransform, other.gameObject.globalTransform
		)
	else
		return geometry.intersecting(self.shape, other, self.gameObject.globalTransform)
	end
end

return Collider