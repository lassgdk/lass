local operators = {}

function operators.nilOr(a, b)
	if a == nil then
		return b
	else
		return a
	end
end

function operators.is(a, b)

	-- how lua checks for equality:
	-- 1. if a and b are not both tables, return a == b.
	-- 2. else, if a and b are both the same table, return true.
	-- 3. else, if rawget(mtA, "__eq") and rawget(mtB, "__eq") are two
	-- different objects, return false.
	-- 4. else, return mtA.__eq(a, b).
	--
	-- (to save you the effort of trying: no, you cannot convince lua that two
	-- different __eq methods are the same by giving them their own metatable
	-- and __eq method.)
	--
	-- thus, we can check for identity like this:
	-- 1. if a ~= b, return false.
	-- 2. else, if type(a) ~= "table", return true.
	-- 3. else, set a.test to a temporary table and return a.test == b.test.

    if a ~= b then
        return false
    end

    if type(a) ~= "table" then
    	return true
	end

	local temp = {}
	local tempA = rawget(a, "temp")
	rawset(a, "temp", temp)

	-- the rawget may be a performance boost if finding b.temp involves more
	-- function calls
	local r = a.temp == rawget(b, "temp")
	rawset(a, "temp", tempA)

	return r
end

return operators
