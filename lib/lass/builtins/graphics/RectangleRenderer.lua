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

	local ySign = 1
	if self.gameObject.gameScene.settings.graphics.invertYAxis then
		ySign = -1
	end

	-- if self.gameObject.name == "Arrow" then
	-- 	debug.log(position, self.gameObject.name)
	-- end

	love.graphics.setColor(self.color)
	love.graphics.setLineWidth(1)
	if globalTransform.rotation == 0 then
		local rect = shape:globalRectangle(globalTransform)

		if self.gameObject.name == "Arrow" then
			-- debug.log(rect.origin)
		end
		love.graphics.rectangle(
			self.mode,
			-- shape.origin.x+position.x,
			-- (shape.origin.y + position.y) * ySign,
			rect.origin.x,
			rect.origin.y * ySign,
			-- shape.width * globalTransform.size.x,
			-- shape.height * globalTransform.size.y
			rect.width,
			rect.height
		)
	else
		local verts = geometry.flattenedVector2Array(self.shape:globalVertices(globalTransform))

		if ySign == -1 then
			for i=2, #verts, 2 do
				verts[i] = verts[i] * ySign
			end
		end

		love.graphics.polygon(self.mode, verts)
	end
end

return RectangleRenderer
