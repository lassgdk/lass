local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

local Camera = class.define(lass.Component)

function Camera:awake()

	self.globals.camera = self
end

function Camera:detach()

	self.globals.camera = self
end

-- function Camera:update()

-- 	local transform = self.globalTransform

-- 	if transform.y <
-- end

function Camera:draw()

	local transform = self.globalTransform
	local ySign = 1
	if self.gameScene.settings.graphics.invertYAxis then
		ySign = -1
	end

	love.graphics.translate(transform.position.x, transform.position.y * ySign)
	love.graphics.rotate(geometry.degreesToRadians(transform.rotation))
	love.graphics.scale(transform.size.x, transform.size.y)
end

return Camera