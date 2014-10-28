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
				newVerts[i] = lass.Vector2(v)
			end
		end

		properties.vertices = newVerts
	else
		properties.vertices = {lass.Vector2(0,0)}
	end

	properties.verticesSource = properties.verticesSource or ""

	self.base.init(self, properties)

	self.globalVertices = {}
end)

function PolygonCollider:update(dt, firstUpdate)

	if firstUpdate and self.verticesSource and self.verticesSource ~= "" then
		self:setVerticesSource(self.verticesSource)
	end

	if self._verticesSource then
		self.vertices = self._verticesSource.vertices
		self.globalVertices = self._verticesSource.globalVertices
	else
		for i, vertex in ipairs(self.vertices) do
			vertices[i] = vertex:rotate(transform.rotation) + transform.position
		end
	end
end

function PolygonCollider:setVerticesSource(source)
	if source then
		self._verticesSource = self.gameObject:getComponent(source)
	else
		self._verticesSource = nil
	end
end

function PolygonCollider:isCollidingWith(other)
	--check if this collider is colliding with another
	--other collider may be a component, or a list of vertices

	if class.instanceof(other, lass.Component) then
		other = other.vertices
	end

	local myvertices = self.globalVertices

	for _, collider in ipairs({myvertices, other}) do
		local len = #collider
		for i, vertex in ipairs(collider) do
			local normal = lass.Vector2.rotate(collider[i+1 % len] - vertex, 90)

			--project all the vertices from both colliders onto the normal
			
			vertex = vertex:project(normal)
		end
	end
end

-- function update(dt)
-- 	self.hitbox.
-- end

return PolygonCollider
