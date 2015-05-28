local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.colliders.Collider")

--[[
RectangleCollider
]]

local RectangleCollider = class.define(Collider, function(self, arguments)

	arguments.shapeSource = arguments.shapeSource or ""
	if not arguments.shapeSource then
		arguments.shape = geometry.Rectangle(arguments.width, arguments.height, arguments.offset)
	else
		--placeholder until shapeSource exists
		arguments.shape = geometry.Rectangle(0,0)
	end

	arguments.width, arguments.height = nil, nil
	self.base.init(self, arguments)
end)

function RectangleCollider:awake()

	if self.shapeSource then
		self.shapeSource = self.gameObject:getComponent(self.shapeSource)
		self.shape = self.shapeSource.shape
	end
	self.base.awake(self)
end

return RectangleCollider