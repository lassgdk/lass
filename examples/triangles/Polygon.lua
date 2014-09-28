lass = require("lass")
class = require("lass.class")

Polygon = class.define(lass.Component, function(self, properties)
	assert(properties.vertices, "must specify vertices")
	properties.mode = properties.mode or "fill"
	properties.color = properties.color or {0,0,0}

	lass.Component.init(self, properties)
end)

function Polygon:update(dt)
	--print(self.gameObject.globalTransform.y)
end

function Polygon:draw()

	local vertices = {}
	local transform = self.gameObject.globalTransform
	--angle in radians (negated for clockwise)
	local angle = (transform.rotation/180) * math.pi

	for i, vertexPoint in ipairs(self.vertices) do

		local axis = "x"
		--remember, i starts at 1...
		if i % 2 == 0 then axis = "y" end

		vertices[i] = vertexPoint * transform.size[axis]

		if axis == "y" then
			local x = vertices[i-1]
			local y = vertices[i]
			vertices[i-1] = (x * math.cos(angle)) - (y * math.sin(angle)) + transform.position.x
			vertices[i] = (x * math.sin(angle)) + (y * math.cos(angle)) + transform.position.y
		end
	end
	love.graphics.setColor(self.color)
	love.graphics.polygon("fill", vertices)
end

return Polygon
