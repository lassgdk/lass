local lass = require("lass")
local class = require("lass.class")

--[[
	polygon renderer
	properties:
		vertices - can be an array of Vector2's (e.g., {{x=1,y=2}, {x=10, y=2}}),
			or a flattened array of coordinates (e.g., {1, 2, 10, 2})
		mode - draw mode, can be "fill" or "line"
		color - rgb tuple, 0-255 (e.g., {0, 0, 200})
]]

local PolygonRenderer = class.define(lass.Component, function(self, properties)

	local originalVType = type(properties.vertices[1])
	assert(
		originalVType == "number" or originalVType == "table",
		"vertices must be all nums or all tables"
	)

	--cast vertices to Vectors and ensure they are not malformed
	if properties.vertices then
		local newVerts = {}

		for i, v in ipairs(properties.vertices) do
			--ensure type consistency
			if i ~= 1 then
				assert(type(v) == originalVType, "vertices must be all nums or all tables")
			end

			if originalVType == "number" and i % 2 == 1 then
				newVerts[math.floor(i/2) + 1] = lass.Vector2(v, properties.vertices[i+1])
			elseif originalVType == "table" then
				newVerts[i] = v
			end	
		end

		properties.vertices = newVerts
	else
		properties.vertices = {lass.Vector2()}
	end

	properties.mode = properties.mode or "fill"
	properties.color = properties.color or {0,0,0}

	--call super constructor
	lass.Component.init(self, properties)

	self.globalVertices = {}
end)

function PolygonRenderer:awake()
end

function PolygonRenderer:update(dt)
	local transform = self.gameObject.globalTransform
	for i, vertex in ipairs(self.vertices) do
		self.globalVertices[i] = lass.Vector2(vertex)
		self.globalVertices[i].x = self.globalVertices[i].x * transform.size.x
		self.globalVertices[i].y = self.globalVertices[i].y * transform.size.y
		self.globalVertices[i] = self.globalVertices[i]:rotate(transform.rotation) + transform.position
	end
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
		vertex = lass.Vector2(vertex) --we don't want to mutate the original vertex
		if self.gameObject.gameScene.settings.graphics.invertYAxis then
			vertex.y = -vertex.y
		end
		vertices[i] = vertex
	end

	love.graphics.setColor(self.color)
	love.graphics.polygon("fill", verticesToFlatArray(vertices))
end

return PolygonRenderer
