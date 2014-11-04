local lass = require("lass")
local class = require("lass.class")
local PolygonCollider = require("lass.builtins.colliders.PolygonCollider")
local PolygonRenderer = require("lass.builtins.graphics.PolygonRenderer")

local PlayerInput = class.define(lass.Component, function(self, properties)

	properties.rotationSpeed = properties.rotationSpeed or 1
	properties.controls = properties.controls or {
		rotate = 1
	}
	if properties.speedMode then
		assert(
			properties.speedMode == "perFrame" or properties.speedMode == "perSecond",
			"invalid speed mode: choose 'perFrame' or 'perSecond'"
		)
	else
		properties.speedmode = "perFrame"
	end

	--call super constructor
	self.base.init(self, properties)

	--hidden variables
	self.rotationDirection = 0

end)

function PlayerInput:awake()
	print(self.gameObject.transform.size)
end

function PlayerInput:update(dt)

	if self.speedMode == "perFrame" then dt = 1 end

	--rotate
	if self.rotationDirection > 0 then
		self.gameObject:rotate(dt * self.rotationSpeed)
	elseif self.rotationDirection < 0 then
		self.gameObject:rotate(dt * -self.rotationSpeed)
	end

	self.base.update(self, dt)
end

function PlayerInput:mousepressed(x, y, button)

	local collider = self.gameObject:getComponent(PolygonCollider)
	-- local renderer = moduleSelf.gameObject:getComponent(PolygonRenderer)

	if collider:isCollidingWith({lass.Vector2(x,-y)}) then

		if button == "l" then
			if self.rotationDirection == -1 then
				self.rotationDirection = 0
			else
				self.rotationDirection = -1
			end
		elseif button == "r" then
			if self.rotationDirection == 1 then
				self.rotationDirection = 0
			else
				self.rotationDirection = 1
			end
		end
	end
end

return PlayerInput
