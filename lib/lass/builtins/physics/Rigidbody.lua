local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.physics.Collider")

local Rigidbody = class.define(lass.Component, function(self, arguments)

	arguments.velocity = geometry.Vector2(arguments.velocity)

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

	--we want the global size and rotation of the shape, but not the global position
	transform.position = geometry.Vector3(0,0,0)

	if shape.class == geometry.Rectangle or shape.class == geometry.Polygon then

		if physicsShape and oldTransform then

			-- we can't directly edit the vertices of a PolygonShape.
			-- if we have a reason to change them, create a new PolygonShape.
			-- else, return nothing
			if
				oldTransform.r ~= transform.r or
				oldTransform.x ~= transform.x or
				oldTransform.y ~= transform.y or
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

function Rigidbody.__get.velocity(self)

	local x, y = self.body:getLinearVelocity()
	return geometry.Vector2(x, y)
end

function Rigidbody.__set.velocity(self, ...)

	if not body then
		self._velocity = geometry.Vector2(...)
	else
		self.body:setLinearVelocity(geometry.Vector2(...))
	end
end

function Rigidbody:awake()

	debug.log(self.gameObject.globalTransform)
	-- self._oldTransform = self.gameObject.globalTransform
	self.body = love.physics.newBody(self.globals.physicsWorld, 0, 0, "dynamic")

	local p = self.gameObject.globalTransform.position
	self.body:setPosition(p.x, p.y * self.globals.ySign)

	if self._velocity then
		self.velocity = self._velocity
		self.velocity = nil
	end

	local colliders = self.gameObject:getComponents(Collider)
	self.fixtures = {}

	for i, collider in ipairs(colliders) do
		local fix = love.physics.newFixture(self.body, shapeToPhysicsShape(self, collider.shape), 1)
		self.fixtures[fix] = collider
	end

	self.gameScene:addEventListener("physicsPreUpdate", self.gameObject, true)
	self.gameScene:addEventListener("physicsPostUpdate", self.gameObject, true)
end

function Rigidbody:update()

	-- local transform = self.gameObject.globalTransform

	-- if
	-- 	self._oldTransform.position.x ~= transform.x or
	-- 	self._oldTransform.position.y ~= transform.y
	-- then
	-- 	self.body:setPosition(transform.position.x, transform.position.y--[[ / self.globals.pixelsPerMeter]])
	-- end

	for i, fixture in ipairs(self.body:getFixtureList()) do
		local collider = self.fixtures[fixture]

		if not collider then
			fixture:destroy()
		else
			local shape = shapeToPhysicsShape(self, collider.shape, fixture:getShape(), self._oldTransform)

			-- if shape, then we weren't able to modify the existing fixture.
			-- we need to replace it
			if shape then
				self.fixtures[fixture] = nil
				fixture:destroy()
				fixture = love.physics.newFixture(self.body, shape, 1)
				self.fixtures[fixture] = collider
			end
		end
	end

	-- self.gameObject.transform.position = 
	-- 	self.gameObject.transform.position - geometry.Vector2(self.body:getPosition())

end

function Rigidbody.events.physicsPreUpdate.play(self, source, data)

	local transform = self.gameObject.globalTransform
	-- debug.log("pre", transform.position, self._oldTransform.position)

	if
		self._oldTransform and (
			self._oldTransform.position.x ~= transform.position.x or
			self._oldTransform.position.y ~= transform.position.y
		)
	then
		-- debug.log("ohno")
		self.body:setPosition(transform.position.x, transform.position.y * self.globals.ySign)
	end

end

function Rigidbody.events.physicsPostUpdate.play(self, source, data)

	local x,y = self.body:getPosition()
	self.gameObject:moveTo(x, y * self.globals.ySign)
	debug.log(x, y, self.gameObject.transform.position, self.gameObject.globalTransform.position)

	self._oldTransform = geometry.Transform(self.gameObject.globalTransform)
	-- debug.log("post2", self._oldTransform.position)
end

return Rigidbody
