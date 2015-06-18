local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")

--[[
Collider - base class for all collider components
do not use this as a component directly! (unless you can think of a good reason to)
]]

local Collider = class.define(lass.Component, function(self, arguments)
	assert(class.instanceof(arguments.shape, geometry.Shape), "shape must be geometry.Shape")

	arguments.ignoreZ = arguments.ignoreZ or false
	arguments.layers = arguments.layers or {"main"}
	arguments.layersToCheck = arguments.layersToCheck or collections.copy(arguments.layers)
	arguments.solid = arguments.solid or false

	self.base.init(self, arguments)
end)

function Collider:awake()

	self.collidingWith = {}
	for i, layerName in ipairs(self.layers) do
		local layer = self.globals.colliders[layerName]
		if layer then
			layer[#layer + 1] = self
			self.globalColliderIndex = #layer
		else
			self.globals.colliders[layerName] = {self}
			self.globalColliderIndex = 1
			-- self.globals.colliders[layerName][self] = true
		end
	end

end

function Collider:isCollidingWith(other)

	local otherType = class.instanceof(other, Collider, geometry.Shape, geometry.Vector2)
	assert(otherType, "other must be a Collider, Shape, or Vector2")

	-- if self.gameObject.name == "Floor" or other.gameObject.name == "Floor" then
	-- 	print("trying")
	-- else
	-- 	print("not trying")
	-- end
	if otherType == Collider then
		if not (
			self.gameObject.transform.position.z == other.gameObject.transform.position.z or
			self.ignoreZ or
			other.ignoreZ
		) then
			return false
		else
			return geometry.intersecting(
				self.shape, other.shape, self.gameObject.globalTransform, other.gameObject.globalTransform
			)
		end
	else
		return geometry.intersecting(self.shape, other, self.gameObject.globalTransform)
	end
end

function Collider:detach()

	local l = nil
	for i, layer in ipairs(self.layers) do
		l = self.globals.colliders[layer]
		table.remove(l, collections.index(l, self))
	end
end
return Collider