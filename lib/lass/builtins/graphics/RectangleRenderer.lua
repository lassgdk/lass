local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Renderer = require("lass.builtins.graphics.Renderer")

--[[
RectangleRenderer
arguments:
	width - number
	height - number
arguments (optional):
	offset - location of top-left corner
	mode - draw mode, can be "fill" or "line"
	color - rgb tuple, 0-255 (e.g., {0, 0, 200})
]]

local RectangleRenderer = class.define(Renderer, function(self, arguments)

	arguments.shape = geometry.Rectangle(arguments.width, arguments.height, geometry.Vector2(arguments.offset))
	arguments.color = arguments.color or {0,0,0}
	arguments.mode = arguments.mode or "fill"

	arguments.width = nil
	arguments.height = nil
	arguments.offset = nil

	self.base.init(self, arguments)
end)

function RectangleRenderer:draw()

	local shape = self.shape
	local globalTransform = self.gameObject.globalTransform
	local position = globalTransform.position

	self:resetCanvas()

	love.graphics.setColor(self.color)
	love.graphics.setLineWidth(1)
	if globalTransform.rotation == 0 then
		local rect = shape:globalRectangle(globalTransform)

		love.graphics.rectangle(
			self.mode,
			rect.origin.x - (rect.width / 2),
			(rect.origin.y + (rect.height / 2)) * self.globals.ySign,
			rect.width,
			rect.height
		)
	else
		local verts = geometry.flattenedVector2Array(self.shape:globalVertices(globalTransform))

		if self.globals.ySign == -1 then
			for i=2, #verts, 2 do
				verts[i] = verts[i] * self.globals.ySign
			end
		end

		love.graphics.polygon(self.mode, verts)
	end
end

return RectangleRenderer
