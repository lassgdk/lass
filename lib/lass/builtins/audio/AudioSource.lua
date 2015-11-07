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

-- function instancesToSteal(self, num)

-- 	--self._instances is a queue, with the least recently played (or never played) at the top
-- 	instances = {}
-- 	for i = 1, num do
-- 		instances[i] = self._instances[i]
-- 	end

-- 	return instances
-- end

function AudioSource.__get.maxInstances(self)

	return self._maxInstances
end

function AudioSource.__set.maxInstances(self, value)

	if value >= 0 then

		if not self._highestInstanceID then
			self._highestInstanceID = 0
		end

		if not self._instances then
			self._instances = {}
		end

		if not self.instanceQueue then
			self.instanceQueue = {}
		end

		if value > #self.instanceQueue then
			-- add new instances
			for i = 1, value - #self.instanceQueue do

				local source = love.audio.newSource(self.filename, self.sourceType)
				self._highestInstanceID = self._highestInstanceID + 1
				self._instances[self._highestInstanceID] = source

				-- insert at the top of the queue so it can be used sooner
				table.insert(self.instanceQueue, 1, self._highestInstanceID)
			end
		elseif value < #self.instanceQueue then
			-- delete extra instances
			for i = value + 1, #self.instanceQueue do

				local instanceID = self.instanceQueue[i]
				self.instanceQueue[i] = nil

				self._instances[instanceID]:stop()
				table.remove(self._instances, instanceID)
			end
		end

		self._maxInstances = value
	else
		error("maxInstances must be greater than or equal to 0")
	end
end

function AudioSource:awake()

	if self.autoplay then
		self:play()
	end
end

function AudioSource.__get.lastInstanceID(self)

	return self.instanceQueue[#self.instanceQueue]
end

function AudioSource.__set.lastInstanceID(self)

	error("attempted to set readonly property 'lastInstanceID'")
end

function AudioSource.__get.firstInstanceID(self)

	return self.instanceQueue[1]
end

function AudioSource.__set.firstInstanceID(self)

	error("attempted to set readonly property 'firstInstanceID'")
end

local function playSource(source)

	if source:isPlaying() then
		source:rewind()
	end

	source:play()
end

local function stopSource(source)
	source:stop()
end

local function pauseSource(source)
	source:pause()
end

local function unpauseSource(source)
	source:resume()
end

local function rewindSource(source)
	source:rewind()
end

for k, v in pairs({
	play = playSource,
	unpause = unpauseSource
}) do
	AudioSource[k] = function(self, instanceID)

		-- send the specified instanceID to the back of the queue.
		-- if instanceID is not specified, pull it from the front of the queue
		if not instanceID then
			instanceID = table.remove(self.instanceQueue, 1)
			self.instanceQueue[#self.instanceQueue + 1] = instanceID
		else
			local index = collections.index(self.instanceQueue, instanceID)
			if not index then
				error("instance " .. tostring(instanceID) .. " not found")
			end

			table.remove(self.instanceQueue, index)
			self.instanceQueue[#self.instanceQueue + 1] = instanceID
		end

		v(self._instances[instanceID])

		return instanceID
	end
end

for k, v in pairs({
	stop = stopSource,
	rewind = rewindSource,
	pause = pauseSource,
}) do
	AudioSource[k] = function(self, instanceID)

		-- send the specified instanceID to the front of the queue.
		-- if instanceID is not specified, pull it from the back of the queue
		if not instanceID then
			instanceID = table.remove(self.instanceQueue, #self.instanceQueue)
			table.insert(self.instanceQueue, 1, instanceID)
		else
			local index = collections.index(self.instanceQueue, instanceID)
			if not index then
				error("instance " .. tostring(instanceID) .. " not found")
			end

			table.remove(self.instanceQueue, index)
			table.insert(self.instanceQueue, 1, instanceID)
		end

		v(self._instances[instanceID])
		return instanceID
	end
end

for k, v in pairs({
	playAll = playSource,
	stopAll = stopSource,
	rewindAll = rewindSource,
	pauseAll = pauseSource,
	unpauseAll = unpauseSource
}) do
	AudioSource[k] = function(self)
		for i, instanceID in ipairs(self.instanceQueue) do
			v(self._instances[instanceID])
		end
	end
end

return AudioSource