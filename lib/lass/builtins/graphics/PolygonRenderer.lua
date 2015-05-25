local lass = require("lass")
local class = require("lass.class")
local Renderer = require("lass.builtins.graphics.Renderer")
local geometry = require("lass.geometry")

--[[
PolygonRenderer
arguments (optional):
	vertices - can be an array of Vector2's (e.g., {{x=1,y=2}, {x=10, y=2}}),
		or a flattened array of coordinates (e.g., {1, 2, 10, 2})
	mode - draw mode, can be "fill" or "line"
	color - rgb tuple, 0-255 (e.g., {0, 0, 200})
]]

local PolygonRenderer = class.define(Renderer, function(self, arguments)

	arguments.shape = geometry.Polygon(arguments.vertices)
	arguments.vertices = nil

	arguments.mode = arguments.mode or "fill"
	arguments.color = arguments.color or {0,0,0}

	--call super constructor
	self.base.init(self, arguments)

	-- self.globalVertices = {}
end)

local function verticesToFlatArray(vertices)

	local flat = {}

	for i, v in ipairs(vertices) do
		flat[i*2 - 1], flat[i*2] = v.x, v.y
	end

	return flat
end

function PolygonRenderer:draw()

	local vertices = {}
	local transform = self.gameObject.globalTransform
	--angle in radians (negated for clockwise)
	local angle = (transform.rotation/180) * math.pi

	for i, vertex in ipairs(self.shape:globalVertices(transform)) do
		vertex = geometry.Vector2(vertex) --we don't want to mutate the original vertex
		if self.gameObject.gameScene.settings.graphics.invertYAxis then
			vertex.y = -vertex.y
		end
		vertices[i] = vertex
	end

	love.graphics.setColor(self.color)
	love.graphics.polygon(self.mode, verticesToFlatArray(vertices))
end

return PolygonRenderer
