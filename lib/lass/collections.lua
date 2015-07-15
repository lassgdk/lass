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
			-- print (index(found, t), t)
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

local function get(object, ...)

	local lastObject = nil
	local tmp = nil
	local key = table.pack(...)

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
			local value
			if type(object) == "table" then
				value = object[key[i+1]]
			elseif type(object) == "function" then
				value = object(object, key[i+1])
			end
			return value, object, key[i+1]
		end
	end
end

local function set(l)

	s = {}
	for i, v in ipairs(l) do
		s[v] = true
	end

	return s
end

return {
	copy = copy,
	deepcopy = deepcopy,
	index = index,
	indices = indices,
	set = set,
	get = get
}
