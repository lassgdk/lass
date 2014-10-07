local lass = require("lass")
local class = require("lass.class")

--this is used for love2d callback functions outside of the component scope
local moduleSelf = {}

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
	lass.Component.init(self, properties)

	--hidden variables
	self.rotationDirection = 0
end)

function PlayerInput:awake()
	moduleSelf = self
end

function PlayerInput:update(dt)

	if self.speedMode == "perFrame" then dt = 1 end

	--rotate
	if self.rotationDirection > 0 then
		self.gameObject:rotate(dt * self.rotationSpeed)
	elseif self.rotationDirection < 0 then
		self.gameObject:rotate(dt * -self.rotationSpeed)
	end

	self._base.update(self, dt)
end

function love.mousepressed(x, y, button)
	print(x, y, button)
	if button == "l" then
		moduleSelf.rotationDirection = -1
	elseif button == "r" then
		moduleSelf.rotationDirection = 1
	end
end

return PlayerInput
