local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

local PolygonCollider = class.define(lass.Component, function(self, properties)

	if properties.vertices then
		local newVerts = {}

		for i, v in ipairs(properties.vertices) do
			--ensure type consistency
			if i ~= 1 then
				assert(type(v) == originalVType, "vertices must be all nums or all tables")
			end

			if originalVType == "number" and i % 2 == 1 then
				newVerts[math.floor(i/2) + 1] = geometry.Vector2(v, properties.vertices[i+1])
			elseif originalVType == "table" then
				newVerts[i] = geometry.Vector2(v)
			end
		end

		properties.vertices = newVerts
	else
		properties.vertices = {geometry.Vector2(0,0)}
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
	end

	if self._verticesSource and self._verticesSource.globalVertices then
		self.globalVertices = self._verticesSource.globalVertices
	else
		local transform = self.gameObject.globalTransform
		for i, vertex in ipairs(self.vertices) do
			self.globalVertices[i] = geometry.Vector2(vertex.x * transform.size.x, vertex.y * transform.size.y)
			self.globalVertices[i] = self.globalVertices[i]:rotate(transform.rotation) + transform.position
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
		other = other.globalVertices
	end

	assert(other, "no vertices found on other collider")

	local myvertices = self.globalVertices

	--check against every normal of every side of both colliders
	for icollider, collider in ipairs({myvertices, other}) do
		local len = #collider

		--if the 2nd collider has only one vertex, we've already checked it
		if len < 2 and icollider == 2 then
			return true
		end

		--for each side of this collider
		for i, vertex in ipairs(collider) do
			local normal = geometry.Vector2.rotate(collider[i%len + 1] - vertex, 90)
			local minDistance = nil
			local maxDistance = nil

			--project the first collider's vertices against the normal
			for j, vertex2 in ipairs(myvertices) do
				local projected = vertex2:project(normal)
				local sm = projected:sqrMagnitude()

				--account for negative values
				if projected.x < 0 or (projected.x == 0 and projected.y < 0) then
					sm = -sm
				end

				if not minDistance or sm < minDistance then
					minDistance = sm
				end
				if not maxDistance or sm > maxDistance then
					maxDistance = sm
				end
			end

			--project the second collider's vertices against the normal
			local potentialCollision = false
			for j, vertex2 in ipairs(other) do
				local projected = vertex2:project(normal)
				local sm = projected:sqrMagnitude()

				--account for negative values
				if projected.x < 0 or (projected.x == 0 and projected.y < 0) then
					sm = -sm
				end

				--if the point is between minDistance and maxDistance, we're potentially colliding
				--(we can assume min and max are not the same, b/c myvertices is never a single point)
				if sm >= minDistance and sm <= maxDistance then
					potentialCollision = true
					break
				end
			end

			if not potentialCollision then
				return false
			end
		end
	end

	--if no gaps have been found, there must be a collision
	return true
end

-- function update(dt)
-- 	self.hitbox.
-- end

return PolygonCollider
