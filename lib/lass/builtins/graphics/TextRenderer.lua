local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Renderer = require("lass.builtins.graphics.Renderer")

local TextRenderer = class.define(Renderer, function(self, arguments)

	arguments.text = arguments.text or ""
	arguments.color = arguments.color or {0,0,0}
	arguments.fontSize = arguments.fontSize or 18
	arguments.boxWidth = arguments.boxWidth or 1000
	arguments.align = arguments.align or "left"
	arguments.offset = geometry.Vector2(arguments.offset)
	arguments.shearFactor = geometry.Vector2(arguments.shearFactor)

	self.base.init(self, arguments)
end)

function TextRenderer:awake()

	self.font = love.graphics.newFont(self.fontSize)
	self.base.awake(self)
end

function TextRenderer:draw()

	local gt = self.gameObject.globalTransform
	local r = math.rad(gt.rotation)
	local ySign = 1

	if self.gameScene.settings.graphics.invertYAxis then
		ySign = -1
	end

	self:resetCanvas()
	love.graphics.setFont(self.font)
	love.graphics.setColor(self.color)
	love.graphics.printf(
		self.text, gt.position.x, gt.position.y * ySign, self.boxWidth, self.align, r,
		gt.size.x, gt.size.y, self.offset.x, self.offset.y * ySign, self.shearFactor.x, self.shearFactor.y
	)
end

return TextRenderer