--[[
standard library overrides
]]

local _print = print
local _tonumber = tonumber

print = function(...)

	_print(...)
	io.flush()
end

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

	print() -- newline

	io.flush()
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
