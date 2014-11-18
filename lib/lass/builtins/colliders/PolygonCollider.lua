local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.colliders.Collider")

--[[
PolygonCollider
]]

local PolygonCollider = class.define(Collider, function(self, arguments)

	arguments.verticesSource = arguments.verticesSource or ""
	if not arguments.verticesSource then
		arguments.shape = geometry.Polygon(arguments.vertices)
	else
		--placeholder until _verticesSource exists
		arguments.shape = geometry.Polygon({})
	end

	arguments.vertices = nil

	self.base.init(self, arguments)
end)

function PolygonCollider:update(dt, firstUpdate)

	if firstUpdate and self.verticesSource and self.verticesSource ~= "" then
		self:setVerticesSource(self.verticesSource)
	end

	if self._verticesSource then
		self.shape = geometry.Polygon(self._verticesSource.shape.vertices)
	end
end

function PolygonCollider:setVerticesSource(source)
	if source then
		self._verticesSource = self.gameObject:getComponent(source)
	else
		self._verticesSource = nil
	end

end

return PolygonCollider
