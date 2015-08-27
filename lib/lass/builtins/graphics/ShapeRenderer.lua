local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")
local Renderer = require("lass.builtins.graphics.Renderer")

--[[
ShapeRenderer

arguments:
	shape (list) - first element must be the name of a lass.geometry shape.
		remaining elements are the arguments for the shape constructor.
		example: {"Rectangle", 10, 20}
arguments (optional):
	mode (string) - draw mode, can be "fill" or "line"
]]


local ShapeRenderer = class.define(Renderer, function(self, arguments)

	--example: {"Rectangle", 30, 40} becomes geometry["Rectangle"](30, 40)
	arguments.shape = geometry[arguments.shape[1]](unpack(collections.copy(arguments.shape, 2)))

	arguments.mode = arguments.mode or "fill"

	self.base.init(self, arguments)
end)

local function drawRectangle(self)

	local rect = self.shape:globalRectangle(self.gameObject.globalTransform)

	love.graphics.rectangle(
		self.mode,
		rect.position.x - (rect.width / 2),
		(rect.position.y + (rect.height / 2)) * self.globals.ySign,
		rect.width,
		rect.height
	)
end

local function drawPolygon(self)

	local verts = geometry.flattenedVector2Array(self.shape:globalVertices(self.gameObject.globalTransform))

	if self.globals.ySign == -1 then
		for i=2, #verts, 2 do
			verts[i] = verts[i] * self.globals.ySign
		end
	end

	love.graphics.polygon(self.mode, verts)
end

local function drawCircle(self)

	local circle = self.shape:globalCircle(self.gameObject.globalTransform)
	love.graphics.circle(
		self.mode,
		circle.position.x,
		circle.position.y * self.globals.ySign,
		circle.radius
	)
end

function ShapeRenderer:draw()

	local globalTransform = self.gameObject.globalTransform
	local position = globalTransform.position

	self:resetCanvas()
	love.graphics.setColor(self.color)
	love.graphics.setLineWidth(1)

	if self.shape:instanceof(geometry.Rectangle) and self.gameObject.globalTransform.rotation == 0 then
		drawRectangle(self)
	elseif class.instanceof(self.shape, geometry.Rectangle, geometry.Polygon) then
		drawPolygon(self)
	elseif self.shape:instanceof(geometry.Circle) then
		drawCircle(self)
	else
		debug.log('idunno')
	end
end

return ShapeRenderer
