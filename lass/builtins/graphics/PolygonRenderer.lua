local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

--[[
PolygonRenderer
properties:
	vertices - can be an array of Vector2's (e.g., {{x=1,y=2}, {x=10, y=2}}),
		or a flattened array of coordinates (e.g., {1, 2, 10, 2})
	mode - draw mode, can be "fill" or "line"
	color - rgb tuple, 0-255 (e.g., {0, 0, 200})
]]

local PolygonRenderer = class.define(lass.Component, function(self, properties)

	properties.polygon = geometry.Polygon(properties.vertices)
	properties.vertices = properties.polygon.vertices

	properties.mode = properties.mode or "fill"
	properties.color = properties.color or {0,0,0}

	--call super constructor
	self.base.init(self, properties)

	-- self.globalVertices = {}
end)

function PolygonRenderer:awake()
end

function PolygonRenderer:update(dt)
	self.vertices = self.polygon.vertices
	self.globalVertices = self.polygon:globalVertices(self.gameObject.globalTransform)
end

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

	for i, vertex in ipairs(self.globalVertices) do
		vertex = geometry.Vector2(vertex) --we don't want to mutate the original vertex
		if self.gameObject.gameScene.settings.graphics.invertYAxis then
			vertex.y = -vertex.y
		end
		vertices[i] = vertex
	end

	love.graphics.setColor(self.color)
	love.graphics.polygon("fill", verticesToFlatArray(vertices))
end

return PolygonRenderer
