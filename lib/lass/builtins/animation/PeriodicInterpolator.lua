lass = require("lass")
class = require("lass.class")
geometry = require("lass.geometry")
collections = require("lass.collections")

local PeriodicInterpolator = class.define(lass.Component, function(self, arguments)

	assert(
		collections.index({"string", "function"}, type(arguments.ifunction)),
		"ifunction must be string or function"
	)
	arguments.amplitude = arguments.amplitude or 1
	arguments.offset = geometry.Vector2(arguments.offset)
	arguments.period = arguments.period or 1 --in seconds
	arguments.sampleLength = arguments.sampleLength or math.pi*2 --math.huge is valid

	self.base.init(self, arguments)

end)

--"gameObject","transform","position","x"
--"gameObject","getComponent","lass.builtins.graphics.SpriteRenderer","color","x"

local function getTarget(self, key)

	-- print(self, key)

	local lastObject = nil
	local tmp = nil
	local object = self

	for i, subkey in ipairs(key) do

		--go down the chain
		if type(object) == "table" then
			lastObject = object
			object = object[subkey]
		--function must be unary other than the "self" argument
		elseif type(object) == "function" then
			tmp = object
			object = object(lastObject, subkey)
			lastObject = tmp
		end

		--if we're on the second-to-last subkey, we've found the target object and its key
		if i >= #key - 1 then
			-- for k,v in pairs(object) do print(k,v) end
			return {object, key[i+1]}
		end
	end
end

function PeriodicInterpolator:awake()

	self.target = getTarget(self, self.target)
	self.lastY = 0
	self:seek(0)

	if self.autoplay then
		self.playing = true
	end
end

function PeriodicInterpolator:seek(x)

	if sampleLength ~= math.huge then
		self.x = (x % self.sampleLength) + self.offset.x
	else
		self.x = x + offsetX
	end
end

function PeriodicInterpolator:update(dt)

	if not self.playing or self.period <= 0 then
		return
	end

	if self.sampleLength ~= math.huge then
		self.x = (self.x + dt * (1 / self.period) * self.sampleLength)
		--wrap around to offset
		self.x = ((self.x - self.offset.x) % self.sampleLength) + self.offset.x
	--if sample length is infinite, x should increase forever
	else
		self.x = self.x + dt * (1 / self.period)
	end

	self.y = (self.ifunction(self.x) * self.amplitude) + self.offset.y
	self.target[1][self.target[2]] = self.target[1][self.target[2]] + (self.y - self.lastY)

	self.lastY = self.y
end

return PeriodicInterpolator