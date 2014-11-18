local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local PolygonCollider = require("lass.builtins.colliders.PolygonCollider")
local PolygonRenderer = require("lass.builtins.graphics.PolygonRenderer")

local PlayerInput = class.define(lass.Component, function(self, arguments)

	arguments.rotationSpeed = arguments.rotationSpeed or 1
	arguments.controls = arguments.controls or {
		rotate = 1
	}
	if arguments.speedMode then
		assert(
			arguments.speedMode == "perFrame" or arguments.speedMode == "perSecond",
			"invalid speed mode: choose 'perFrame' or 'perSecond'"
		)
	else
		arguments.speedmode = "perFrame"
	end
	arguments.resizeAmount = arguments.resizeAmount or 0

	--call super constructor
	self.base.init(self, arguments)

	--hidden variables
	self.rotationDirection = 0
end)

function PlayerInput:awake()
end

function PlayerInput:update(dt, firstUpdate)

	-- if firstUpdate then
	-- 	print(self.gameObject.name, self.gameObject.transform.position, self.gameObject.globalTransform.position)
	-- end

	if self.speedMode == "perFrame" then dt = 1 end

	--rotate
	if self.rotationDirection > 0 then
		self.gameObject:rotate(dt * self.rotationSpeed)
	elseif self.rotationDirection < 0 then
		self.gameObject:rotate(dt * -self.rotationSpeed)
	end
end

function PlayerInput:mousepressed(x, y, button)

	if button ~= "l" and button ~= "r" then
		if button == "wu" and self.resizeAmount and self.resizeAmount ~= 0 then
			self.gameObject:resize(self.resizeAmount, self.resizeAmount, 0)
		elseif button == "wd" and self.resizeAmount and self.resizeAmount ~= 0 then
			self.gameObject:resize(-self.resizeAmount, -self.resizeAmount, 0)
		end
	end

	local collider = self.gameObject:getComponent(PolygonCollider)

	if collider:isCollidingWith(geometry.Vector2(x,-y)) then

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
