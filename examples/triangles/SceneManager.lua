lass = require("lass")
class = require("lass.class")
geometry = require("lass.geometry")

local SceneManager = class.define(lass.Component, function(self, arguments)

	arguments.zoomAmount = arguments.zoomAmount or .1
	arguments.message = arguments.message or ""
	arguments.fontSize = arguments.fontSize or 18

	self.base.init(self, arguments)
end)

function SceneManager:awake()
	self.font = love.graphics.newFont(18)
end

function SceneManager:draw()
	local pos = self.gameObject.globalTransform.position
	local r = geometry.degreesToRadians(self.gameObject.globalTransform.rotation)

	love.graphics.setFont(self.font)
	love.graphics.setColor(240,240,240)
	love.graphics.printf(self.message, pos.x, -pos.y, 1000, "left", r)
end

return SceneManager