local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")

local EventTrigger = class.define(lass.Component, function(self, arguments)

	arguments.events = arguments.events or {}
	self.base.init(self, arguments)
end)

local function postEvents(self)

	for i, event in ipairs(self.events) do
		if type(event) == "string" then
			self.globals.events[event]:play(self)
		elseif type(event) == "table" then
			self.globals.events[event[1]]:post(event[2], self)
		end
	end
end

for i, callback in ipairs({
	{"awake", {"firstAwake"}},
	{"update", {"dt"}},
	{"errhand", {"message"}},
	{"focus", {"focused"}},
	{"keypressed", {"key", "repeat"}},
	{"keyreleased", {"key"}},
	{"mousefocus", {"focused"}},
	{"mousemoved", {"x", "y", "dx", "dy"}},
	{"mousepressed", {"x", "y", "button", "clickedOn"}},
	{"mousereleased", {"x","y", "button", "clickedOn"}},
	{"quit", {}},
	{"windowresize", {"width", "height"}},
	{"textinput", {"text"}},
	{"threaderror", {"thread", "message"}},
	{"visible", {"visibility"}},
	{"collisionenter", {"other"}},
	{"collisionexit", {"other", "noCollisionsLeft"}},
}) do
	EventTrigger[callback[1]] = function(self, ...)

		local cond = self.conditions[callback[1]]
		if not cond then
			return
		end

		-- {"x", "y", "z"} => {x=1, y=2, z=3}
		local params = {}
		for i, v in ipairs(callback[2]) do
			params[v] = i
		end

		if type(cond) == "function" and cond(self, ...) then
			postEvents(self)
		elseif type(cond) == "table" then

			local callbackArgs = table.pack(...)

			for k, v in pairs(cond) do
				if callbackArgs[params[k]] ~= v then
					return
				end
				-- if all conditions are correct, trigger the events
				postEvents(self)
			end
		elseif cond == true then
			postEvents(self)
		end
	end
end

return EventTrigger
