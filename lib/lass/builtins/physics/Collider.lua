local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")

--[[
Collider

arguments (optional):
	shape (list, default=nil) - first element must be the name of a lass.geometry shape.
		remaining elements are the arguments for the shape constructor.
		example: {"Rectangle", 10, 20}
	shapeSource (list, default=nil) - key chain pointing to shape object. must be specified
		if shape is not specified.
		see lass.collections.get for key chain documentation.
	ignoreZ (boolean, default=false)
	layers (list, default={"main"}) - names of layers to add the collider to.
	layersToCheck (list, default=layers) - names of layers to check against for collisions.
	solid (boolean, default=false) - if true, rigidbodies cannot pass through this object.
]]

local Collider = class.define(lass.Component, function(self, arguments)

	--example: {"Rectangle", 30, 40} becomes geometry["Rectangle"](30, 40)
	if not arguments.shapeSource then
		arguments.shape = geometry[arguments.shape[1]](unpack(collections.copy(arguments.shape, 2)))
		assert(class.instanceof(arguments.shape, geometry.Shape), "shape must be geometry.Shape")
	end

	arguments.ignoreZ = arguments.ignoreZ or false
	arguments.layers = arguments.layers or {"main"}
	arguments.layersToCheck = arguments.layersToCheck or collections.copy(arguments.layers)
	arguments.solid = arguments.solid or false

	self.base.init(self, arguments)
end)

function Collider:awake(firstAwake)

	if self.shapeSource and firstAwake then
		-- self.shapeSource = self.gameObject:getComponent(self.shapeSource)
		self.shapeSource = collections.get(self, unpack(self.shapeSource))
		self.shape = self.shapeSource.shape
	end

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

function Collider:deactivate()

	for i, layerName in ipairs(self.layers) do
		local layer = self.globals.colliders[layerName]
		local index

		for i, c in ipairs(layer) do
			if c == self then
				index = i
				break
			end
		end

		assert(index, "Collider missing from globals.colliders." .. layerName)

		table.remove(layer, index)
	end

	self.base.deactivate(self)
end

function Collider:isCollidingWith(other, direction)

	local otherType = class.instanceof(other, Collider, geometry.Shape, geometry.Vector2)
	assert(otherType, "other must be a Collider, Shape, or Vector2")

	if otherType == Collider then
		if not (
			self.gameObject.globalTransform.position.z == other.gameObject.globalTransform.position.z or
			self.ignoreZ or
			other.ignoreZ
		) then
			return false
		else
			return geometry.intersecting(
				self.shape, other.shape, self.gameObject.globalTransform, other.gameObject.globalTransform,
				false, false, direction
			)
		end
	else
		return geometry.intersecting(self.shape, other, self.gameObject.globalTransform, false, false, direction)
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