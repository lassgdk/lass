require("lass")
require("lass.class")

PlayerInput = class(Component, function(self, properties)

	properties.speed = properties.speed or 1
	properties.directions = properties.directions or {
		up="up", down="down", left="left", right="right", leftTurn="a", rightTurn="d"
	}
	if properties.speed then
		assert(
			properties.speedMode == "perFrame" or properties.speedMode == "perSecond",
			"invalid speed mode: choose 'perFrame' or 'perSecond'"
		)
	else
		properties.speedmode = "perFrame"
	end

	Component.init(self, properties)
end)

function PlayerInput:update(dt)

	dt = self.speedMode == "perSecond" or 1

	--up/down
	if self.directions.up and love.keyboard.isDown(self.directions.up) then
		self.gameObject:move(0, -self.speed * dt)
	elseif self.directions.down and love.keyboard.isDown(self.directions.down) then
		self.gameObject:move(0, self.speed * dt)
	end

	--left/right
	if self.directions.up and love.keyboard.isDown(self.directions.left) then
		self.gameObject:move(-self.speed * dt, 0)
	elseif self.directions.down and love.keyboard.isDown(self.directions.right) then
		self.gameObject:move(self.speed * dt, 0)
	end

	--rotate
	if self.directions.right and love.keyboard.isDown(self.directions.rightTurn) then
		self.gameObject:rotate(1)
	elseif self.directions.left and love.keyboard.isDown(self.directions.leftTurn) then
		self.gameObject:rotate(-1)
	end

	self._base.update(self, dt)
end

return PlayerInput
