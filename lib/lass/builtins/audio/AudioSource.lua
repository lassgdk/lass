local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

local AudioSource = class.define(lass.Component, function(self, arguments)

	arguments.source = love.audio.newSource(
		arguments.filename or "", arguments.sourceType or "static"
	)
	arguments.autoplay = arguments.autoplay or false

	self.base.init(self, arguments)
end)

function AudioSource:awake()

	if self.autoplay then
		self.source:play()
	end
end

return AudioSource