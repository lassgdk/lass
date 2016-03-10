--[[
standard library overrides
]]

local _print = print
local _tonumber = tonumber
local _ipairs = ipairs

local function iter(a, i)

	if type(a) ~= "table" then
		error("bad argument #1 to 'ipairs' (table expected, got " .. type(a) .. ")")
	end
	i = i + 1

	--default ipairs seems to use rawget(a, i) instead of a[i]
	local v = a[i]
	if v then
		return i, v
	end
end

local _print = print


print = function(...)

	_print(...)
	io.flush()
end

-- ipairs = function(a)

-- 	return iter, a, 0
-- end

tonumber = function(x, b)

	local mt = getmetatable(x)

	if mt and mt.__tonumber then
		return mt.__tonumber(x, b)
	else
		return _tonumber(x, b)
	end
end

table.pack = function(...)
	return { n = select("#", ...), ... }
end

debug.logs = function(...)

	local info = debug.getinfo(2)
	local a = table.pack(...)
	local sep = "\t"
	local s = ""

	a[a.n + 1] = "(" .. info.short_src .. ", line " .. info.currentline .. ")"
	a.n = a.n + 1

	for i = 1, a.n do
		s = s .. tostring(a[i])

		if i < a.n then
			s = s .. sep
		end
	end

	return s
end

debug.log = function(...)

	local info = debug.getinfo(2)
	local a = table.pack(...)
	local sep = "\t"

	a[a.n + 1] = "(" .. info.short_src .. ", line " .. info.currentline .. ")"
	a.n = a.n + 1

	for i = 1, a.n do
		io.write(tostring(a[i]))

		if i < a.n then
			io.write(sep)
		end
	end

	print() -- newline and io flush
end


math.sign = function(n)

	if n < 0 then
		return -1
	elseif n > 0 then
		return 1
	else
		return 0
	end
end

-- code from http://lua-users.org/wiki/SimpleRound
-- by Igor Skoric
math.round = function(num, idp)

	local mult = 10^(idp or 0)
	
    if num >= 0 then
    	return math.floor(num * mult + 0.5) / mult
    else
    	return math.ceil(num * mult - 0.5) / mult
    end
end

string.join = function(j, list)

	local joined = ""

	for i, s in ipairs(list) do
		if i > 1 then
			joined = joined .. j .. s
		else
			joined = joined .. s
		end
	end

	return joined
end