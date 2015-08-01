local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Camera = require("lass.builtins.graphics.Camera")

--[[
Renderer - base class for all renderer components
do not use this as a component directly! (unless you can think of a good reason to)
]]

local Renderer = class.define(lass.Component, function(self, arguments)

	arguments.color = arguments.color or {0,0,0}
	arguments.canvas = arguments.canvas or "main"
	self.base.init(self, arguments)
end)

function Renderer:awake()

	if not self.gameObject:getComponent(Camera) then
		self.globals.drawables[self.gameObject] = true
		self.globals.canvases[self.canvas] = self.globals.canvases[self.canvas] or love.graphics.newCanvas()
	end
end

function Renderer:resetCanvas()

	local cnv = self.globals.canvases[self.canvas]
	if love.graphics.getCanvas() ~= cnv then
		local r,g,b = love.graphics.getBackgroundColor()
		love.graphics.setCanvas(cnv)
		cnv:clear(r,g,b)
	end
end

function Renderer:detach()

	self.globals.drawables[self.gameObject] = nil
end

return Renderer
