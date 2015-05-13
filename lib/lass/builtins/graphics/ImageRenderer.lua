local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

local ImageRenderer = class.define(lass.Component, function(self, arguments)
	arguments.image = love.graphics.newImage(arguments.filename)
	arguments.origin = geometry.Vector2(arguments.origin)
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
		self.origin.x,
		self.origin.y * ySign
	)
end

return ImageRenderer
