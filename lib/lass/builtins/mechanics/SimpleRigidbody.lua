local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.colliders.Collider")
local Renderer = require("lass.builtins.graphics.Renderer")

local SimpleRigidbody = class.define(lass.Component, function(self, arguments)

	arguments.airResistance = arguments.airResistance or 0
	arguments.velocity = geometry.Vector2()

	self.collisions = {}
	self.base.init(self, arguments)
end)

function SimpleRigidbody:update(dt)

	if not self.gameObject.done then
		self.velocity = self.velocity - self.globals.gravity
		local r = self.gameObject:move(self.velocity.x * dt, self.velocity.y * dt, 0, true)
	else
		self.velocity = geometry.Vector2(0,0)
	end

	-- if r then
	-- 	self.collisions = r
	-- 	self.velocity = geometry.Vector2(0,0)
	-- else
	-- 	for i, c in pairs(self.collisions) do
	-- 		if self.gameObject:getComponent(Collider).collidingWith[c] then
	-- 			self.velocity = geometry.Vector2(0,0)
	-- 		end
	-- 	end
	-- end
	-- else
		-- print(self.gameObject.transform.position, self.gameObject.globalTransform.position)
	-- end
end

function SimpleRigidbody:collisionenter(colliders)
	self.gameObject:getComponent(Renderer).color[2] = 200
end

return SimpleRigidbody