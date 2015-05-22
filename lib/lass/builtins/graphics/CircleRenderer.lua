local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

--[[
CircleRenderer
arguments (optional):
	radius
	center - Vector2
	mode - draw mode, can be "fill" or "line"
	color - rgb tuple, 0-255 (e.g., {0, 0, 200})
]]

local CircleRenderer = class.define(lass.Component, function(self, arguments)

	arguments.shape = geometry.Circle(arguments.radius or 0, arguments.center)
	arguments.radius = nil
	arguments.color = arguments.color or {0,0,0}
	arguments.mode = arguments.mode or "fill"

	self.base.init(self, arguments)
end)

function CircleRenderer:draw()

	local pos = self.gameObject.globalTransform.position + self.shape.center

	--eventually we will allow for ovals -- in the meantime, x affects the overall radius
	local size = self.gameObject.globalTransform.size.x

	local sign = 1
	if self.gameObject.gameScene.settings.graphics.invertYAxis then
		sign = -1
	end

	love.graphics.setColor(self.color)
	love.graphics.circle(self.mode, pos.x, sign * pos.y, self.shape.radius * size)
end

return CircleRenderer
