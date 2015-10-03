local settings = require("settings")
require("lass.stdext")

function love.conf(t)
	t.window = nil
	for groupName, group in pairs(settings) do
		if type(group) == "table" and groupName ~= "window" and t[groupName] then
			for optionName, option in pairs(group) do
				t[groupName][optionName] = option
			end
		else
			t[groupName] = group
		end
	end
end