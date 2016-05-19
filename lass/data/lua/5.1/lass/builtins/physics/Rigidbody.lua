local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.physics.Collider")

local Rigidbody = class.define(lass.Component, function(self, arguments)

	arguments.velocity = geometry.Vector2(arguments.velocity)

	lass.Component.init(self, arguments)
end)

function Rigidbody.__get.velocity(self)

	local v = geometry.Vector2(self.body:getLinearVelocity())

	v.callback = function(object, key, value)
		local vel = self.velocity

		if key == "x" then
			self.velocity = geometry.Vector2(value, vel.y)
		elseif key == "y" then
			self.velocity = geometry.Vector2(vel.x, value)
		end
	end

	return v
end

function Rigidbody.__set.velocity(self, value)

	if not self.body then
		self._velocity = value
	else
		self.body:setLinearVelocity(value.x, value.y)
	end
end

function Rigidbody.__get.angularVelocity(self)

	local r = self.body:getAngularVelocity()
	return math.deg(r)
end

function Rigidbody.__set.angularVelocity(self, r)

	self.body:setAngularVelocity(math.rad(r))
end

function Rigidbody:__tostring()
	return "Rigidbody"
end

function Rigidbody:awake()

	self.body = love.physics.newBody(self.globals.physicsWorld, 0, 0, "dynamic")

	local p = self.gameObject.globalTransform.position
	self.body:setPosition(p.x, p.y * self.globals.ySign)
	self.body:setAngle(math.rad(self.gameObject.globalTransform.rotation))

	if self._velocity then
		self.velocity = self._velocity
		self._velocity = nil
	end

	-- local colliders = self.gameObject:getComponents(Collider)
	-- self.fixtures = {}

	-- for i, collider in ipairs(colliders) do
	-- 	local fix = love.physics.newFixture(self.body, shapeToPhysicsShape(self, collider.shape), 1)
	-- 	fix:setRestitution(collider.restitution)
	-- 	self.fixtures[fix] = collider
	-- end

	self.gameScene:addEventListener("physicsPreUpdate", self.gameObject, true)
	self.gameScene:addEventListener("physicsPostUpdate", self.gameObject, true)
end

function Rigidbody:deactivate()

	self.body:destroy()
	lass.Component.deactivate(self)
end

function Rigidbody.events.physicsPreUpdate.play(self, source, data)

	local transform = self.gameObject.globalTransform

	-- if the transform has changed independently of physics transformations,
	-- we need to reset the body position and rotation
	-- (the size is accounted for in the fixture update)
	if
		self._oldTransform and (
			self._oldTransform.position.x ~= transform.position.x or
			self._oldTransform.position.y ~= transform.position.y
		)
	then
		self.body:setPosition(transform.position.x, transform.position.y * self.globals.ySign)
		self.body:setAngle(math.rad(transform.rotation))
		self.body:setAwake(true)
	end
end

function Rigidbody.events.physicsPostUpdate.play(self, source, data)

	local x,y = self.body:getPosition()
	self.gameObject:moveToGlobal(x, y * self.globals.ySign)

	local angle = math.deg(self.body:getAngle())
	self.gameObject.transform.rotation = angle - self.gameObject.parent.globalTransform.rotation

	self._oldTransform = geometry.Transform(self.gameObject.globalTransform)
end

return Rigidbody
