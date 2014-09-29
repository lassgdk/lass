local utils = {}

function utils.indexof(list, value)
	--find first index of value in numeric table

	for i, entity in ipairs(list) do
		if entity == value then
			return i
		end
	end
end

return utils
