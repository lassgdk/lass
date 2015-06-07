local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")

--[[
PeriodicInterpolator - a class for smoothly and periodically modifying gameObject parameters.
	TODO: more type checking?

arguments:
	ifunction - a unary function, or a string reference to a lass.geometry unary function.
		the value (hereafter referred to as X) passed to it will increase linearly with time.
		the output of ifunction shall be hereafter referred to as Y.
		example: function(x) return x^2 end
arguments (optional):
	target (list, default={}) - the target parameter to modify using Y.
		it should be constructed as a "chain" of keys; the first key will be indexed from self. each
		key can refer to either a table or a binary function; the last key can refer to a value of
		any type. if it refers to a function, the table the function belongs to will be passed as
		the first argument, and the value of the next key will be passed as the second argument.
		example: {"gameObject", "transform", "position", "x"}
		example 2: {"gameObject", "getComponent", "MyComponent", "myvar"}
	amplitude (number, default=1) - amplitude by which to multiply Y
	offset (Vector2, default={0,0}) - the amounts to add to X and Y
	sampleLength - the highest possible value of X (minus offset.x). can be infinite.
	period (number, default=1) - duration of the interpolation in seconds.
		or, if sampleLength is infinite, rate at which X increases.
]]


local PeriodicInterpolator = class.define(lass.Component, function(self, arguments)

	assert(
		collections.index({"string", "function"}, type(arguments.ifunction)),
		"ifunction must be string or function"
	)
	if type(arguments.ifunction) == "string" then
		arguments.ifunction = geometry.functions[arguments.ifunction]
	end

	arguments.targets = arguments.targets or {}
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

	-- self.targets = getTarget(self, self.targets)
	-- for i, t in ipairs(self.targets) do
	-- 	self.targets[i] = getTarget(self, t)
	-- end
	self.lastY = 0
	self:seek(0)

	if self.autoplay then
		self.playing = true
	end

end

function PeriodicInterpolator:seek(x)

	if self.sampleLength ~= math.huge then
		self.x = (x % self.sampleLength) + self.offset.x
	else
		self.x = x + self.offset.x
	end
end

function PeriodicInterpolator:update(dt)

	local targets = {}
	for i, t in ipairs(self.targets) do
		targets[i] = getTarget(self, t)
	end

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

	for i, target in ipairs(targets) do
		if type(target[2]) == "function" then
			target[1][target[2]](target[1], self.y - self.lastY)
		else
			target[1][target[2]] = target[1][target[2]] + (self.y - self.lastY)
		end
	end

	self.lastY = self.y
end

return PeriodicInterpolator