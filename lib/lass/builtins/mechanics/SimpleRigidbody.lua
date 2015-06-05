local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.colliders.Collider")
local Renderer = require("lass.builtins.graphics.Renderer")

local SimpleRigidbody = class.define(lass.Component, function(self, arguments)

	arguments.airResistance = arguments.airResistance or 0
	arguments.velocity = geometry.Vector2(arguments.velocity)

	self.collisions = {}
	self.base.init(self, arguments)
end)

function SimpleRigidbody:update(dt)

	self.velocity = self.velocity - self.globals.gravity

	for i, axis in ipairs({"x", "y"}) do
		local moveBy = geometry.Vector2()
		moveBy[axis] = self.velocity[axis] * dt

		local r = self.gameObject:move(moveBy, true)
		-- local r = self.gameObject:move(self.velocity.x * dt, self.velocity.y * dt, 0, true)
		if r == false then
			self.velocity[axis] = 0-- = geometry.Vector2(0,0)
		end
	end

end

return SimpleRigidbody