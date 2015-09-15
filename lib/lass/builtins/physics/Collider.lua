local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")
local Rigidbody = nil

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
	arguments.restitution = arguments.restitution or 0

	self.base.init(self, arguments)
end)

local function shapeToPhysicsShape(self, shape, physicsShape, oldTransform)
	-- create or modify a physics shape using a geometry.Shape

	-- only Circle physics shapes can be modified, which makes this function's signature
	-- somewhat complicated:

	-- if physicsShape is not specified, return a new physics shape.
	-- if shape and physicsShape are not the same shape type, return a new physics shape.
	-- if shape and physicsShape are circles, modify physicsShape and return nil.
	-- if shape and physicsShape are polygons, and self.globalTransform == oldTransform,
	-- do nothing and return nil.
	-- if shape and physicsShape are polygons, and self.globalTransform ~= oldTransform,
	-- return a new physics shape.

	-- all of this is to say: if you specify physicsShape and this function returns a new
	-- physics shape, you should destroy the old shape and replace it with the new one.

	local transform = geometry.Transform(self.gameObject.globalTransform)

	-- we want the global size of the shape, but not the global position or rotation
	-- (we will use the rotation for the body, but not the fixture)
	transform.position = geometry.Vector3(0,0,0)
	transform.rotation = 0

	if shape.class == geometry.Rectangle or shape.class == geometry.Polygon then

		if physicsShape and oldTransform then

			-- we can't directly edit the vertices of a PolygonShape.
			-- if we have a reason to change them, create a new PolygonShape.
			-- else, return nothing
			if
				-- oldTransform.r ~= transform.r or
				oldTransform.size.x ~= transform.size.x or
				oldTransform.size.y ~= transform.size.y or
				not physicsShape:typeOf("PolygonShape")
			then
				local verts = shape:globalVertices(transform)
				for i, vert in ipairs(verts) do
					vert.y = vert.y * self.globals.ySign
				end
				return love.physics.newPolygonShape(unpack(geometry.flattenedVector2Array(verts)))
			end
		else
			local verts = shape:globalVertices(transform)
			for i, vert in ipairs(verts) do
				vert.y = vert.y * self.globals.ySign
			end
			return love.physics.newPolygonShape(unpack(geometry.flattenedVector2Array(verts)))
		end

	elseif shape.class == geometry.Circle then
		local cir = shape:globalCircle(transform)

		-- thankfully, we can directly edit the radius and center of a CircleShape
		if physicsShape and physicsShape:typeOf("CircleShape") then
			physicsShape:setRadius(cir.radius)
			physicsShape:setPoint(cir.position.x, cir.position.y * self.globals.ySign)
		else
			return love.physics.newCircleShape(cir.position.x, cir.position.y * self.globals.ySign, cir.radius)
		end
	end
end

function Collider.__get.solid(self)

	return self._solid
end

function Collider.__set.solid(self, value)

	self._solid = value

	-- if not attached to Rigidbody, create a new static body or destroy the current body
	if not self.rigidbody and self.gameObject then

		if value == true then
			if (self.body and self.body:isDestroyed()) or not self.body then
				local pos = self.gameObject.globalTransform.position
				pos.y = pos.y * self.globals.ySign

				self.body = love.physics.newBody(self.globals.physicsWorld, pos.x, pos.y, "static")
				self.fixture = love.physics.newFixture(self.body, shapeToPhysicsShape(self, self.shape), 1)
			end
		elseif value == false and self.body and not self.body:isDestroyed() then
			self.body:destroy()
			self.fixture:destroy()
		end

	--else, set self.body to the rigidbody or destroy the current body
	elseif self.rigidbody and self.body ~= self.rigidbody.body then

		if value == true then
			self.body = self.rigidbody.body
			self.fixture = love.physics.newFixture(self.body, shapeToPhysicsShape(self, self.shape), 1)
		elseif value == false then
			self.fixture:destroy()
		end
	end
end

function Collider.__get.fixture(self)

	return self._fixture
end

function Collider.__set.fixture(self, value)
	-- debug.log("setting fixture of " .. self.gameObject.name)
	if self._fixture then
		self._fixture:destroy()
		self.globals.physicsFixtures[self._fixture] = nil
	end

	self.globals.physicsFixtures[value] = self
	self._fixture = value
end

function Collider.__get.rigidbody(self)

	if not Rigidbody then
		Rigidbody = require("lass.builtins.physics.Rigidbody")
	end

	--TODO: account for rigidbody being on an ancestor GameObject
	if not (self.gameObject and self.solid) then
		return nil
	else
		return self.gameObject:getComponent(Rigidbody)
	end
end

function Collider.__set.rigidbody(self)
	error("attempted to set \"rigidbody\" (a read-only property)")
end

function Collider:awake(firstAwake)

	if self.shapeSource and firstAwake then
		-- self.shapeSource = self.gameObject:getComponent(self.shapeSource)
		self.shapeSource = collections.get(self, unpack(self.shapeSource))
		self.shape = self.shapeSource.shape
	end

	self.collidingWith = {}
	self.notCollidingWith = {}

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

	-- if self.gameObject.name == "floor" then
		self.gameScene:addEventListener("physicsPreUpdate", self.gameObject, true)
		self.gameScene:addEventListener("physicsPostUpdate", self.gameObject, true)
	-- end

	-- for i,v in ipairs(self.gameObject.events) do
		-- debug.log(i,v)
	-- end

	-- if self.solid is true but self.body was destroyed, setting self.solid to
	-- true again will trigger construction of a new self.body
	self.solid = self.solid
end

function Collider:__tostring()
	return "Collider"
end


function Collider.events.physicsPreUpdate.play(self, source, data)

	self.solid = self.solid

	if self.body then
		-- debug.log(self.gameObject.name, self.gameObject.globalTransform.position, self.body:getPosition())

		local transform = self.gameObject.globalTransform

		-- if the transform has changed independently of physics transformations,
		-- we need to reset the body position
		if
			self._oldTransform and
			not self.rigidbody and (
				self._oldTransform.position.x ~= transform.position.x or
				self._oldTransform.position.y ~= transform.position.y
			)
		then
			-- debug.log(self.gameObject.name)
			self.body:setPosition(transform.position.x, transform.position.y * self.globals.ySign)
		end

		-- debug.log(self._oldTransform)
		local shape = shapeToPhysicsShape(self, self.shape, self.fixture:getShape(), self._oldTransform)

		-- if shape, then we weren't able to modify the existing fixture.
		-- we need to replace it
		if shape then
			self.fixture = love.physics.newFixture(self.body, shape, 6)
		end

		self.fixture:setRestitution(self.restitution)
	end
end

function Collider.events.physicsPostUpdate.play(self, source, data)

	self._oldTransform = geometry.Transform(self.gameObject.globalTransform)
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

	if self.body and not self.rigidbody then
		self.body:destroy()
	end

	if self.fixture then
		self.fixture:destroy()
	end

	self.base.deactivate(self)
end

function Collider:isCollidingWith(other, direction, noFrameRepeat, storeCollisionData)

	local otherType = class.instanceof(other, Collider, geometry.Shape, geometry.Vector2)
	assert(otherType, "other must be a Collider, Shape, or Vector2")

	if storeCollisionData == nil then
		storeCollisionData = true
	end

	local r, d = false, nil
	if otherType == Collider then

		if noFrameRepeat then
			if self.collidingWith[other] and self.collidingWith[other].frame == self.gameScene.frame then
				-- debug.log(other.gameObject.name, "collide")
				return true, self.collidingWith[other]
			elseif self.notCollidingWith[other] and self.notCollidingWith[other].frame == self.gameScene.frame then
				return false
			end
		end

		-- if z values don't match and neither collider ignores z, collision is false
		if not (
			self.gameObject.globalTransform.position.z == other.gameObject.globalTransform.position.z or
			self.ignoreZ or
			other.ignoreZ
		) then
			r = false
		else
			r, d = geometry.intersecting(
				self.shape, other.shape, self.gameObject.globalTransform, other.gameObject.globalTransform,
				false, false, direction
			)
		end

		if r then
			d.direction = direction
		end

		if storeCollisionData then
			if r then
				d.frame = self.gameScene.frame

				local selfData, otherData = collections.deepcopy(d), collections.deepcopy(d)

				if direction then
					otherData.direction.x = -otherData.direction.x
					otherData.direction.y = -otherData.direction.y
				end

				self.collidingWith[other] = selfData
				other.collidingWith[self] = otherData
			else
				self.notCollidingWith[other] = {frame = self.gameScene.frame}
				other.notCollidingWith[self] = {frame = self.gameScene.frame}
			end
		end

	else
		r, d = geometry.intersecting(
			self.shape, other, self.gameObject.globalTransform, nil, false, false, direction
		)
	end

	return r, d
end

function Collider:detach()

	local l = nil
	for i, layer in ipairs(self.layers) do
		l = self.globals.colliders[layer]
		table.remove(l, collections.index(l, self))
	end
end

return Collider