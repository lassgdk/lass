local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.colliders.Collider")

--[[
PolygonCollider
]]

local PolygonCollider = class.define(Collider, function(self, properties)

	properties.verticesSource = properties.verticesSource or ""
	if not properties.verticesSource then
		properties.shape = geometry.Polygon(properties.vertices)
	else
		--placeholder until _verticesSource exists
		properties.shape = geometry.Polygon({})
	end

	self.base.init(self, properties)
end)

function PolygonCollider:update(dt, firstUpdate)

	if firstUpdate and self.verticesSource and self.verticesSource ~= "" then
		self:setVerticesSource(self.verticesSource)
	end

	if self._verticesSource then
		self.shape = geometry.Polygon(self._verticesSource.shape)
	end
end

function PolygonCollider:setVerticesSource(source)
	if source then
		self._verticesSource = self.gameObject:getComponent(source)
	else
		self._verticesSource = nil
	end

end

-- function PolygonCollider:isCollidingWith(other)
-- 	-- for i, v in ipairs(self.shape.vertices) do
-- 	-- 	print(i,v)
-- 	-- end
-- 	-- print(class.instanceof(self.shape, geometry.Polygon))-- == geometry.Polygon)
-- 	return geometry.intersecting(self.shape, other, self.gameObject.globalTransform)
-- end

return PolygonCollider
