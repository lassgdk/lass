local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")
local operators = require("lass.operators")
local Renderer = require("lass.builtins.graphics.Renderer")

local TextRenderer = class.define(Renderer, function(self, arguments)

	local text = operators.nilOr(arguments.text, "")
	arguments.text = nil
	arguments.color = arguments.color or {0,0,0}
	arguments.box = operators.nilOr(arguments.box, geometry.Rectangle(100, 100))
	-- arguments.boxSize = geometry.Vector2(operators.nilOr(arguments.boxSize, {x=100, y=100})
	arguments.fontSize = arguments.fontSize or 18
	-- arguments.boxWidth = arguments.boxWidth or 1000
	arguments.align = arguments.align or "left"
	arguments.hideOverflow = operators.nilOr(arguments.hideOverflow, true)
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
	if self.hideOverflow then
		local _, lines = getFont(self):getWrap(value, self.box.width)
		local lineHeight = getFont(self):getHeight()
		local maxLines = self.box.height / lineHeight
		
		if #lines > maxLines then
			value = string.join("\n", collections.copy(lines, 1, maxLines))
			debug.log(value)
		end
	end
	getTextObject(self):setf(value, self.box.width, self.align)
end

function TextRenderer:draw()

	local gt = self.gameObject.globalTransform
	local size = gt.size
	local r = math.rad(gt.rotation)
	local ySign = self.globals.ySign

	--set size to 1, so we can use the draw function for scaling.
	--note that globalTransform is accessed via a getter, so modifying it
	--isn't permanent
	gt.size = geometry.Vector3(1,1,1)
	local rect = self.box:globalRectangle(gt)

	self:resetCanvas()
	love.graphics.setColor(self.color)
	love.graphics.draw(
		self._textObject,
		rect.position.x,
		rect.position.y * ySign,
		r,
		size.x,
		size.y,
		rect.width/2,-- 0,
		-rect.height/2 * ySign,
		self.shearFactor.x,
		self.shearFactor.y
	)
end

return TextRenderer
