local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

local SpriteRenderer = class.define(lass.Component, function(self, arguments)

	self.base.init(self, arguments)
end)

return SpriteRenderer
