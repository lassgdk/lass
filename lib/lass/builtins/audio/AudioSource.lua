local lass = require("lass")
local class = require("lass.class")
local operators = require("lass.operators")
local collections = require("lass.collections")
local geometry = require("lass.geometry")

local AudioSource = class.define(lass.Component, function(self, arguments)

	-- arguments.source = love.audio.newSource(
	-- 	arguments.filename or "", arguments.sourceType or "static"
	-- )
	arguments.autoplay = operators.nilOr(arguments.autoplay, false)
	arguments.streaming = arguments.streaming or false
	arguments.maxInstances = operators.nilOr(arguments.maxInstances, 1)

	local volume = operators.nilOr(arguments.volume, 1)
	local minVolume = operators.nilOr(arguments.minVolume, 0)
	local maxVolume = operators.nilOr(arguments.maxVolume, 1)
	local looping = operators.nilOr(arguments.looping, false)
	arguments.volume = nil
	arguments.minVolume = nil
	arguments.maxVolume = nil
	arguments.looping = nil

	self.__base.init(self, arguments)

	self.minVolume = minVolume
	self.maxVolume = maxVolume
	self.volume = volume
	self.looping = looping
end)

local function newInstance(self, instance)

	if not instance then

		local sourceType
		if self.streaming then
			sourceType = "stream"
		else
			sourceType = "static"
		end

		return {source = love.audio.newSource(self.filename, sourceType)}
	else
		return {source = instance.source:clone()}
	end
end

local function playInstance(self, instance, target)

	target = target or self.gameObject
	local source = instance.source

	if not source:isPaused() then
		instance.target = target

		if source:isPlaying() then
			source:rewind()
		end
	end

	source:play()
end

local function stopInstance(self, instance)
	instance.source:stop()
end

local function pauseInstance(self, instance)
	instance.source:pause()
end

local function unpauseInstance(self, instance)
	instance.source:resume()
end

local function rewindInstance(self, instance)
	instance.source:rewind()
end

local function setCurrentTimeOfInstance(self, instance, time)
	instance.source:seek(time, "seconds")
end

local function setCurrentSampleOfInstance(self, instance, sample)
	instance.source:seek(time, "samples")
end

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

			local instance = nil
			for i = 1, value - #self.instanceQueue do

				instance = newInstance(self, instance)

				self._highestInstanceID = self._highestInstanceID + 1
				self._instances[self._highestInstanceID] = instance

				-- insert at the top of the queue so it can be used sooner
				table.insert(self.instanceQueue, 1, self._highestInstanceID)
			end
		elseif value < #self.instanceQueue then
			-- delete extra instances
			for i = value + 1, #self.instanceQueue do

				local instanceID = self.instanceQueue[i]
				self.instanceQueue[i] = nil

				self._instances[instanceID].source:stop()
				table.remove(self._instances, instanceID)
			end
		end

		self._maxInstances = value
	else
		error("maxInstances must be greater than or equal to 0")
	end
end

function AudioSource.__get.lastInstanceID(self)
	return self.instanceQueue[#self.instanceQueue]
end
AudioSource.__set.lastInstanceID = nil

function AudioSource.__get.firstInstanceID(self)
	return self.instanceQueue[1]
end
AudioSource.__set.firstInstanceID = nil

function AudioSource:awake()

	if self.autoplay then
		self:play()
	end

	self.gameScene:addEventListener("physicsPostUpdate", self.gameObject)
end

function AudioSource.events.physicsPostUpdate.play(self)

	for i, instanceID in ipairs(self.instanceQueue) do
		local instance = self._instances[instanceID]
		if instance.target and instance.source:getChannels() == 1 then
			local position = instance.target.globalTransform.position
			instance.source:setPosition(position.x, position.y * self.globals.ySign)
		end
	end
end

--[[
level getters
]]

function AudioSource.__get.volume(self)

	return self._volume
end

function AudioSource:getVolumeOffset(instanceID)

	return operators.nilOr(self._instances[instanceID].volumeOffset, 0)
end

function AudioSource.__get.minVolume(self)

	debug.log(self._instances[self.instanceQueue[1]])
	local min = self._instances[self.instanceQueue[1]].source:getVolumeLimits()
	return min
end

function AudioSource.__get.maxVolume(self)

	local _, max = self._instances[self.instanceQueue[1]].source:getVolumeLimits()
	return max
end

function AudioSource:getVolumeLimits(self)
	--at least as fast as getting min and max individually

	return self._instances[self.instanceQueue[1]].source:getVolumeLimits()
end

--[[
level setters
]]

function AudioSource.__set.volume(self, value)

	self._volume = value

	for i, instanceID in ipairs(self.instanceQueue) do
		local offset = self:getVolumeOffset(instanceID)
		self._instances[instanceID].source:setVolume(offset + value)
	end
end

function AudioSource:setVolumeOffset(instanceID, offset)

	local instance = self._instances[instanceID]
	instance.volumeOffset = offset
	instance.source:setVolume(offset + self.volume)
end

function AudioSource.__set.minVolume(self, value)

	local instance
	for i, instanceID in ipairs(self.instanceQueue) do
		instance = self._instances[instanceID]
		instance.source:setVolumeLimits(value, self.maxVolume)
	end
end

function AudioSource.__set.maxVolume(self, value)

	local instance
	for i, instanceID in ipairs(self.instanceQueue) do
		instance = self._instances[instanceID]
		instance.source:setVolumeLimits(self.minVolume, value)
	end
end

function AudioSource:setVolumeLimits(self, min, max)
	--faster than individually setting min and max, as long as you're changing
	--both

	local instance
	for i, instanceID in ipairs(self.instanceQueue) do
		instance = self._instances[instanceID]
		instance.source:setVolumeLimits(min, max)
	end
end

--[[
misc getters
]]

function AudioSource.__get.looping(self)
	return self._instances[self.instanceQueue[1]].source:isLooping()
end

--[[
misc setters
]]

function AudioSource.__set.looping(self, value)

	local instance
	for i, instanceID in ipairs(self.instanceQueue) do
		instance = self._instances[instanceID]
		instance.source:setLooping(value)
	end
end

--[[
property getters
]]

function AudioSource.__get.numChannels(self)
	return self._instances[self.instanceQueue[1]].source:channels()
end
AudioSource.__set.numChannels = nil

--[[
state getters

these methods and getters return information about a Source's playing state.
when an instance ID isn't specified, we pick the instance at the front of the queue.
]]

function AudioSource:getCurrentTime(instanceID)

	instanceID = operators.nilOr(instanceID, self.instanceQueue[1])
	return self._instances[instanceID].source:tell("seconds")
end

function AudioSource.__get.currentTime(self)
	return self:getCurrentTime()
end

function AudioSource:getCurrentSample(instanceID)

	instanceID = operators.nilOr(instanceID, self.instanceQueue[1])
	return self._instances[instanceID].source:tell("samples")
end

function AudioSource.__get.currentSample(self)
	return self:getCurrentSample()
end

for k, v in pairs({
	isPlaying = "playing",
	isPaused = "paused",
	isStopped = "stopped"
}) do

	AudioSource[k] = function(self, instanceID)

		--if no instance ID is specified, pick the front of the queue
		instanceID = operators.nilOr(instanceID, self.instanceQueue[1])
		local instance = self._instances[instanceID]
		return instance[k](instance)
	end

	AudioSource.__get[v] = function(self)
		return AudioSource[k](self)
	end

	AudioSource.__set[v] = nil

	AudioSource.__get[v .. "All"] = function(self)

		for i, instanceID in ipairs(self.instanceQueue) do
			if not AudioSource[k](self, instanceID) then
				return false
			end
		end

		return true
	end

	AudioSource.__set[v .. "All"] = nil
end

--[[
state changers

these methods and getters change a Source's playing state.
play and unpause move the chosen instance to the back of the queue.
all others move the instance to the front of the queue.
]]

function AudioSource.__set.currentTime(self, value)
	self:setCurrentTime(value)
end

function AudioSource.__set.currentSample(self, value)
	self:setCurrentSample(value)
end

for k, v in pairs({
	play = playInstance,
	unpause = unpauseInstance
}) do
	AudioSource[k] = function(self, ...)

		local args = table.pack(...)
		local target = nil
		local instanceID = nil

		if k == "play" and #args > 0 then
			if type(args[1]) == "number" then
				instanceID = args[1]
			else
				target = args[1]
				instanceID = args[2]
			end
		elseif k == "unpause" then
			instanceID = args[1]
		end

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

		v(self, self._instances[instanceID], target)

		return instanceID
	end
end

for k, v in pairs({
	stop = stopInstance,
	rewind = rewindInstance,
	pause = pauseInstance,
	setCurrentTime = setCurrentTimeOfInstance,
	setCurrentSample = setCurrentSampleOfInstance
}) do
	AudioSource[k] = function(self, instanceID, extra)

		if k == "setCurrentTime" or k == "setCurrentSample" then
			instanceID, extra = extra, instanceID
		end

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

		v(self, self._instances[instanceID], extra)
		return instanceID
	end
end

for k, v in pairs({
	playAll = playInstance,
	stopAll = stopInstance,
	rewindAll = rewindInstance,
	pauseAll = pauseInstance,
	unpauseAll = unpauseInstance,
	setCurrentTimeAll = setCurrentTimeOfInstance,
	setCurrentSampleAll = setCurrentSampleOfInstance
}) do
	AudioSource[k] = function(self, ...)
		for i, instanceID in ipairs(self.instanceQueue) do
			v(self, self._instances[instanceID], ...)
		end
	end
end

return AudioSource