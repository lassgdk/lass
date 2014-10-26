local lass = require("lass")
local class = require("lass.class")

local PolygonCollider = class.define(lass.Component, function(self, properties)

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
		properties.vertices = {{x=0,y=0}}
	end

	properties.trackVerticesFrom = properties.trackVerticesFrom or ""

	self.base.init(self, properties)
end)

function PolygonCollider:update()
	if self.trackVerticesFrom ~= "" then
		self.vertices = self.gameObject:getComponent(self.trackVerticesFrom).vertices
	end
end

function PolygonCollider:isCollidingWith(other)
	--check if this collider is colliding with another
	--other collider may be a component, or a list of vertices

	if class.instanceof(other, lass.Component) then
		other = other.vertices
	end

	local vertices = {}
	local transform = self.gameObject.globalTransform

	for i, vertex in ipairs(self.vertices) do
		vertices[i] = vertex:rotate(transform.rotation) + transform.position
	end

	for i, vertex in ipairs(vertices) do
		local normal = lass.Vector2.rotate(vertices[i+1] - vertex, 90)

	end
end

-- function update(dt)
-- 	self.hitbox.
-- end

return PolygonCollider
