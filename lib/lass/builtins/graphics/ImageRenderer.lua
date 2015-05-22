local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

--[[
ImageRenderer

arguments:
	filename - string
arguments (optional):
	offset (Vector2, default={x=0,y=0}) - location of top left corner
	color - rgb tuple, 0-255 (e.g., {0, 0, 200})
]]

local ImageRenderer = class.define(lass.Component, function(self, arguments)
	arguments.image = love.graphics.newImage(arguments.filename)
	arguments.offset = geometry.Vector2(arguments.offset)
	arguments.color = arguments.color or {255,255,255}

	self.base.init(self, arguments)
end)

function ImageRenderer:draw()

	local globalTransform = self.gameObject.globalTransform
	local ySign = 1
	if self.gameObject.gameScene.settings.graphics.invertYAxis then
		ySign = -1
	end
	love.graphics.setColor(self.color)
	love.graphics.draw(
		self.image,
		globalTransform.position.x,
		globalTransform.position.y * ySign,
		(globalTransform.rotation/180) * math.pi,
		globalTransform.size.x,
		globalTransform.size.y,
		-self.offset.x,
		-self.offset.y * ySign
	)
end

return ImageRenderer
