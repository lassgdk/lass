local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.collision.Collider")

local SimpleRigidbody = class.define(lass.Component, function(self, arguments)

	arguments.airResistance = arguments.airResistance or 0
	arguments.velocity = geometry.Vector2(arguments.velocity)

	self.collisions = {}
	self.base.init(self, arguments)
end)

function SimpleRigidbody:update(dt)

	self.velocity = self.velocity - self.globals.gravity

	local breakAfterY = true
	for i, axis in ipairs({"x", "y", "x"}) do
		local moveBy = geometry.Vector2()
		moveBy[axis] = self.velocity[axis] * dt

		local r = self.gameObject:move(moveBy, true)
		if r == false then
			-- if collision happened during horizontal movement, try again after vertical movement
			if i == 1 then
				breakAfterY = false
			else
				self.velocity[axis] = 0
			end
		end

		-- even if not breakAfterY, there's no point in trying again if vertical movement was 0
		if i == 2 and (breakAfterY or moveBy[axis] == 0) then
			break
		end
	end

end

return SimpleRigidbody