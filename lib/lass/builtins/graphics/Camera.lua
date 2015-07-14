local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

local Camera = class.define(lass.Component, function(self, arguments)

	arguments.canvas = arguments.canvas or "main"
	self.base.init(self, arguments)
end)

function Camera:awake()

	self.globals.cameras[self.canvas] = self
end

-- function Camera:update()

-- 	local transform = self.globalTransform

-- 	if transform.y <
-- end

function Camera:draw()

	local transform = self.gameObject.globalTransform
	local ySign = 1
	if self.gameScene.settings.graphics.invertYAxis then
		ySign = -1
	end

	love.graphics.translate(-transform.position.x, -transform.position.y * ySign)
	love.graphics.rotate(math.rad(-transform.rotation))
	love.graphics.scale(1/transform.size.x, 1/transform.size.y)
end

return Camera