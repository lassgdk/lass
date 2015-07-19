local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Renderer = require("lass.builtins.graphics.Renderer")

--[[
ImageRenderer

arguments:
	filename - string
arguments (optional):
	offset (Vector2, default={x=0,y=0}) - location of top left corner
	color - rgb tuple, 0-255 (e.g., {0, 0, 200})
]]

local ImageRenderer = class.define(Renderer, function(self, arguments)

	arguments.image = love.graphics.newImage(arguments.filename)
	arguments.offset = geometry.Vector2(arguments.offset)
	arguments.color = arguments.color or {255,255,255}

	self.base.init(self, arguments)
end)

function ImageRenderer:draw()

	local globalTransform = self.gameObject.globalTransform
	local ySign = self.globals.ySign
	local width, height = self.image:getDimensions()

	-- love.graphics.setCanvas(self.globals.canvases[self.canvas])
	self:resetCanvas()

	love.graphics.setColor(self.color)
	love.graphics.draw(
		self.image,
		globalTransform.position.x,
		-- globalTransform.position.x - width/2,
		(globalTransform.position.y) * ySign,
		-- (globalTransform.position.y + height/2) * ySign,
		(globalTransform.rotation/180) * math.pi,
		globalTransform.size.x,
		globalTransform.size.y,
		-self.offset.x + width/2,
		(-self.offset.y - height/2) * ySign
	)
end

return ImageRenderer
