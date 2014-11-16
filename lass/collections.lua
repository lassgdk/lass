class = require("lass.class")

--[[list functions]]

local function index(list, value, keyfunc)
	--find first index of value in an ordered list

	for i, entity in ipairs(list) do
		if (keyfunc and keyfunc(entity) == value) or (not keyfunc and entity == value) then
			return i
		end
	end
end

local function indices(list, value, keyfunc)
	--find all indices of value in an ordered list

	local indices = nil

	for i, entity in ipairs(list) do
		if (keyfunc and keyfunc(entity) == value) or (not keyfunc and entity == value) then
			if not indices then
				indices = {i}
			else
				indices[#indices + 1] = i
			end
		end
	end

	return indices
end

local function copy(t)
	--shallow copy

	if type(t) == "table" then
		local _copy = {}

		for k,v in pairs(t) do
			_copy[k] = v
		end

		return _copy
	else
		return t
	end
end

local function deepcopy(t, found)
	--recursive deepcopy (avoid using for very large/deep tables)
	--circular references will not be copied

	if type(t) == "table" then

		if not found or not index(found, t) then
			found = copy(found) or {}
			found[#found + 1] = t

			local _copy = {}
			for k, v in pairs(t) do
				_copy[k] = deepcopy(v, found)
			end

			return _copy
		else
			print (index(found, t), t)
			return nil
		end

		-- local _copy = {}

		-- for k,v in pairs(t) do
		-- 	if not index(found, v) then
		-- 		found = copy(found)
		-- 		found[#found + 1] = v
		-- 		_copy[k] = deepcopy(v, found)
		-- 	end
		-- end

		-- return _copy
	else
		return t
	end
end

return {
	copy = copy,
	deepcopy = deepcopy,
	index = index,
	indices = indices
}
