local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Camera = require("lass.builtins.graphics.Camera")

--[[
Renderer - base class for all renderer components
do not use this as a component directly! (unless you can think of a good reason to)
]]

local Renderer = class.define(lass.Component)

function Renderer:awake()

	if not self.gameObject:getComponent(Camera) then
		self.globals.drawables[self.gameObject] = true
	end
end

function Renderer:detach()

	self.globals.drawables[self.gameObject] = nil
end

return Renderer
