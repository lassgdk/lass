local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")

local MouseClickHandler = class.define(lass.Component, function(self, arguments)

	arguments.targetArguments = arguments.targetArguments or {}
	self.base.init(self, arguments)
end)

local function mouseEvent(self, f, x, y, button, clickedOnSelf)

	local targets = {}
	for i, t in ipairs(self.targets) do
		local object, key = collections.getkey(self, unpack(t))
		targets[i] = {object, key}
	end

	for i, target in ipairs(targets) do

		if type(target[1][target[2]]) == "function" then
			if type(self.targetArguments[i]) == "table" then
				target[1][target[2]](target[1], unpack(self.targetArguments[i]))
			elseif type(self.targetArguments[i]) == "function" then
				target[1][target[2]](target[1], self.targetArguments[i](f, x, y, button, clickedOnSelf))
			else
				target[1][target[2]](target[1])
			end
		else
			-- if type(self.targetArguments[i]) == "table" then
			if type(self.targetArguments[i]) == "function" then
				target[1][target[2]] = self.targetArguments[i](f, x, y, button, clickedOnSelf)
			else
				target[1][target[2]] = self.targetArguments[i]
				-- target[1][target[2]](target[1])
			end
		end
	end
end

for i, f in ipairs({"mousepressed", "mousereleased"}) do
	MouseClickHandler[f] = function(self, x, y, button, clickedOnSelf)

		if type(self.conditions) == "function" then
			if self.conditions(f, x, y, button, clickedOnSelf) then
				mouseEvent(self, f, x, y, button, clickedOnSelf)
			end
		elseif type(self.conditions) == "table" then

			local keys = {
				event=f, x=x, y=y, button=button, clickedOnSelf=clickedOnSelf
			}
			for k, acceptableSet in pairs(self.conditions) do

				--if at least one value in the set is matched, the condition is true
				--(essentially, we are implementing the 'or' function)
				if type(acceptableSet) == "table" then
					for j, acceptableValue in ipairs(acceptableSet) do
						if keys[k] == acceptableValue then
							break
						end
						if j == #acceptableValue then
							return
						end
					end
				--if acceptableSet is not a table, assume it is the value to check
				else
					if keys[k] ~= acceptableSet then
						return
					end
				end
			end

			mouseEvent(self, f, x, y, button, clickedOnSelf)
		end
	end
end

return MouseClickHandler