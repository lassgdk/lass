local lass = require("lass")
local class = require("lass.class")
local collections = require("lass.collections")
local geometry = require("lass.geometry")

local AudioSource = class.define(lass.Component, function(self, arguments)

	-- arguments.source = love.audio.newSource(
	-- 	arguments.filename or "", arguments.sourceType or "static"
	-- )
	arguments.autoplay = arguments.autoplay or false
	arguments.maxInstances = arguments.maxInstances or 1

	self.base.init(self, arguments)
end)

function instancesToSteal(self, num)

	--self.instances is a stack, with the least recently played (or never played) at the top
	instances = {}
	for i = 1, num do
		instances[i] = self.instances[i]
	end

	return instances
end

function AudioSource.__get.maxInstances(self)

	return self._maxInstances
end

function AudioSource.__set.maxInstances(self, value)

	if value >= 0 then

		if not self.instances then
			self.instances = {}
		end

		if value > #self.instances then
			-- add new instances. we want to insert them at the top of the stack so we can
			-- steal them sooner
			for i = 1, value - #self.instances do
				table.insert(self.instances, 1, love.audio.newSource(self.filename, self.sourceType))
			end
		elseif value < #self.instances then
			-- delete extra instances
			local instances = instancesToSteal(self, #self.instances - value)
			for i, inst in ipairs(instances) do
				inst:stop()
				table.remove(self.instances, collections.index(inst))
			end
		end

		self._maxInstances = value
	else
		error("maxInstances must be greater than or equal to 0")
	end
end

function AudioSource:awake()

	self._currentInstance = 0
	if self.autoplay then
		self:play()
	end
end

function AudioSource:play(instance)

	self._currentInstance = (self._currentInstance + 1) % self.maxInstances
	if self._currentInstance == 0 then
		self._currentInstance = self.maxInstances
	end

	self.instances[self._currentInstance]:rewind()
	self.instances[self._currentInstance]:play()
end

return AudioSource