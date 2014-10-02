local lass = require("lass")
local class = require("lass.class")

local PlayerInput = class.define(lass.Component, function(self, properties)

	properties.speed = properties.speed or 1
	properties.controls = properties.controls or {
		up="up", down="down", left="left", right="right",
		leftTurn="a", rightTurn="d", sizeUp="c", sizeDown="z"
	}
	if properties.speed then
		assert(
			properties.speedMode == "perFrame" or properties.speedMode == "perSecond",
			"invalid speed mode: choose 'perFrame' or 'perSecond'"
		)
	else
		properties.speedmode = "perFrame"
	end

	lass.Component.init(self, properties)
end)

function PlayerInput:update(dt)

	if self.speedMode == "perFrame" then dt = 1 end

	--up/down
	if self.controls.up and love.keyboard.isDown(self.controls.up) then
		self.gameObject:move(0, -self.speed * dt)
	elseif self.controls.down and love.keyboard.isDown(self.controls.down) then
		self.gameObject:move(0, self.speed * dt)
	end

	--left/right
	if self.controls.left and love.keyboard.isDown(self.controls.left) then
		self.gameObject:move(-self.speed * dt, 0)
	elseif self.controls.right and love.keyboard.isDown(self.controls.right) then
		self.gameObject:move(self.speed * dt, 0)
	end

	--rotate
	if self.controls.rightTurn and love.keyboard.isDown(self.controls.rightTurn) then
		self.gameObject:rotate(1)
	elseif self.controls.leftTurn and love.keyboard.isDown(self.controls.leftTurn) then
		self.gameObject:rotate(-1)
	end

	--resize
	if self.controls.sizeUp and love.keyboard.isDown(self.controls.sizeUp) then
		self.gameObject:resize(self.speed * dt, 0)
	elseif self.controls.sizeDown and love.keyboard.isDown(self.controls.sizeDown) then
		self.gameObject:resize(-self.speed * dt, 0)
	end

	self._base.update(self, dt)
end

return PlayerInput
