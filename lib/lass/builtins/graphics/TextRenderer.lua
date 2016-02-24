local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local operators = require("lass.operators")
local Renderer = require("lass.builtins.graphics.Renderer")

local TextRenderer = class.define(Renderer, function(self, arguments)

	local text = operators.nilOr(arguments.text, "")
	arguments.text = nil
	arguments.color = arguments.color or {0,0,0}
	arguments.fontSize = arguments.fontSize or 18
	arguments.boxWidth = arguments.boxWidth or 1000
	arguments.align = arguments.align or "left"
	arguments.offset = geometry.Vector2(arguments.offset)
	arguments.shearFactor = geometry.Vector2(arguments.shearFactor)

	self.__base.init(self, arguments)

	self.text = text
end)

local function getFont(self)

	if not self._font then
		self._font = love.graphics.newFont(self.fontSize)
	end

	return self._font
end

local function getTextObject(self)

	if not self._textObject then
		self._textObject = love.graphics.newText(getFont(self))
	end

	return self._textObject
end

function TextRenderer.__get.text(self)
	return self._text
end

function TextRenderer.__set.text(self, value)

	self._text = value
	getTextObject(self):setf(value, self.boxWidth, self.align)
end

function TextRenderer:awake()

	-- self._font = love.graphics.newFont(self.fontSize)
	-- self._textObject = love.graphics.newText()
	self.__base.awake(self)
end

function TextRenderer:draw()

	local gt = self.gameObject.globalTransform
	local r = math.rad(gt.rotation)
	local ySign = self.globals.ySign

	self:resetCanvas()
	love.graphics.setColor(self.color)
	love.graphics.draw(
		self._textObject,
		gt.position.x,
		gt.position.y * ySign,
		r,
		gt.size.x,
		gt.size.y,
		-self.offset.x + self.boxWidth/2,
		-self.offset.y * ySign,
		self.shearFactor.x,
		self.shearFactor.y
	)
	-- love.graphics.setFont(self._font)
	-- love.graphics.printf(
	-- 	self.text,
	-- 	gt.position.x,
	-- 	gt.position.y * ySign,
	-- 	self.boxWidth,
	-- 	self.align,
	-- 	r,
	-- 	gt.size.x,
	-- 	gt.size.y,
	-- 	-self.offset.x + self.boxWidth/2,
	-- 	-self.offset.y * ySign,
	-- 	self.shearFactor.x,
	-- 	self.shearFactor.y
	-- )
end

return TextRenderer
