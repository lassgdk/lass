class = require("lass.class")

local collections = {}

function collections.index(list, value, keyfunc)
	--find first index of value in an ordered list

	for i, entity in ipairs(list) do
		if (keyfunc and keyfunc(entity) == value) or (not keyfunc and entity == value) then
			return i
		end
	end
end

function collections.indices(list, value, keyfunc)
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

function collections.copy(t, firstIndex, lastIndex)
	--shallow copy

	if type(t) == "table" then
		local _copy = {}

		if firstIndex then
			local i2 = 1
			for i = firstIndex, (lastIndex or #t) do
				_copy[i2] = t[i]
				i2 = i2 + 1
			end
		else
			for k,v in pairs(t) do
				_copy[k] = v
			end
		end

		return _copy
	else
		return t
	end
end

function collections.deepcopy(t, found)
	--recursive deepcopy (avoid using for very large/deep tables)
	--circular references will not be copied

	if type(t) == "table" then

		if not found or not collections.index(found, t) then
			--use a copy of found, to prevent the original being altered down
			--the stack
			found = collections.copy(found) or {}
			found[#found + 1] = t

			local _copy = {}

			-- preserve the metatable if it exists
			local mt = getmetatable(t)
			if mt then
				setmetatable(_copy, mt)
			end

			for k, v in pairs(t) do
				-- if v is a reference to t's metatable, only copy the reference
				if v == mt then
					_copy[k] = v
				-- else, deep copy it
				else
					_copy[k] = collections.deepcopy(v, found)
				end
			end


			return _copy
		else
			return nil
		end
	else
		return t
	end
end

function collections.map(func, list)

	local mapped = {}
	for i, v in ipairs(list) do
		mapped[i] = func(v)
	end

	return mapped
end

function collections.range(start, stop, skip)

	skip = skip or 1
	list = {}

	i = 1
	for v = start, stop, skip do
		list[i] = v
		i = i + 1
	end

	return list
end

local function _get(object, calculateValue, ...)

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
		else
			error("object must be table or function")
		end

		--if we're on the second-to-last subkey, we've found the target object and its key
		if i >= #key - 1 then
			-- for k,v in pairs(object) do print(k,v) end
			if calculateValue then
				local value
				if type(object) == "table" then
					value = object[key[i+1]]
				elseif type(object) == "function" then
					value = object(lastObject, key[i+1])
				end
				return value, object, key[i+1]
			else
				return object, key[i+1]
			end
		end
	end
end

function collections.get(object, ...)

	return _get(object, true, ...)
end

function collections.getkey(object, ...)

	return _get(object, false, ...)
end

function collections.set(l)

	s = {}
	for i, v in ipairs(l) do
		s[v] = true
	end

	return s
end

function collections.keys(t)

	local _keys = {}

	for k, v in pairs(t) do
		_keys[#keys + 1] = k
	end

	return _keys
end

function collections.random(l)

	if #l then
		return l[math.random(1, #l)]
	end
end

return collections