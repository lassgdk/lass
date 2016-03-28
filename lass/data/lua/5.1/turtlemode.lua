local m = {}

local function wraptest(got, msg, reason)
	assert(got, reason .. "\n" .. msg)
end

---got == true.
-- (Named "assert_true" to not conflict with standard assert.)
-- @param msg Message to display with the result.
function m.assert_true(got, msg)
	wraptest(got, msg, string.format("Expected success, got %s.", tostring(got)))
end

---got == false.
function m.assert_false(got, msg)
	wraptest(not got, msg, string.format("Expected false, got %s", tostring(got)))
end

--got == nil
function m.assert_nil(got, msg)
	wraptest(got == nil, msg, string.format("Expected nil, got %s", tostring(got)))
end

--got ~= nil
function m.assert_not_nil(got, msg)
	wraptest(got ~= nil, msg, string.format("Expected non-nil value, got %s", tostring(got)))
end

local function tol_or_msg(t, m)
	if not t and not m then return 0, nil
	elseif type(t) == "string" then return 0, t
	elseif type(t) == "number" then return t, m
	else error("Neither a numeric tolerance nor string")
	end
end


---exp == got.
function m.assert_equal(exp, got, tol, msg)
	tol, msg = tol_or_msg(tol, msg)
	if type(exp) == "number" and type(got) == "number" then
   	wraptest(math.abs(exp - got) <= tol, msg, string.format("Expected %s +/- %s, got %s",
                         	tostring(exp), tostring(tol), tostring(got)))
	else
   	wraptest(exp == got, msg, string.format("Expected %q, got %q", tostring(exp), tostring(got)))
	end
end

---exp ~= got.
function m.assert_not_equal(exp, got, msg)
	wraptest(exp ~= got,
	msg,
   "Expected something other than " .. tostring(exp))
end

---val > lim.
function m.assert_gt(lim, val, msg)
	wraptest(val > lim,
	msg,
	string.format("Expected a value > %s, got %s",
                      	tostring(lim), tostring(val)))
end

---val >= lim.
function m.assert_gte(lim, val, msg)
	wraptest(val >= lim,
	msg,
	string.format("Expected a value >= %s, got %s",
                      	tostring(lim), tostring(val)))
end

---val < lim.
function m.assert_lt(lim, val, msg)
	wraptest(val < lim,
	msg,
	string.format("Expected a value < %s, got %s",
                      	tostring(lim), tostring(val)))
end

---val <= lim.
function m.assert_lte(lim, val, msg)
	wraptest(val <= lim,
	msg,
	string.format("Expected a value <= %s, got %s",
                      	tostring(lim), tostring(val)))
end

---#val == len.
function m.assert_len(len, val, msg)
	wraptest(#val == len,
	msg,
	string.format("Expected #val == %d, was %d",
                      	len, #val))
end

---#val ~= len.
function m.assert_not_len(len, val, msg)
	wraptest(#val ~= len,
	msg,
	string.format("Expected length other than %d", len))
end

---Test that the string s matches the pattern exp.
function m.assert_match(pat, s, msg)
	s = tostring(s)
	wraptest(type(s) == "string" and s:match(pat),
	msg,
	string.format("Expected string to match pattern %s, was %s",
                      	pat,
                         (s:len() > 30 and (s:sub(1,30) .. "...")or s)))
end

---Test that the string s doesn't match the pattern exp.
function m.assert_not_match(pat, s, msg)
	wraptest(type(s) ~= "string" or not s:match(pat),
	msg,
	string.format("Should not match pattern %s", pat))
end

---Test that val is a boolean.
function m.assert_boolean(val, msg)
	wraptest(type(val) == "boolean",
	msg,
	string.format("Expected type boolean but got %s",
	type(val)))
end

---Test that val is not a boolean.
function m.assert_not_boolean(val, msg)
	wraptest(type(val) ~= "boolean",
	msg,
	string.format("Expected type other than boolean but got %s",
	type(val)))
end

---Test that val is a number.
function m.assert_number(val, msg)
	wraptest(type(val) == "number",
	msg,
	string.format("Expected type number but got %s",
	type(val)))
end

---Test that val is not a number.
function m.assert_not_number(val, msg)
	wraptest(type(val) ~= "number",
	msg,
	string.format("Expected type other than number but got %s",
	type(val)))
end

---Test that val is a string.
function m.assert_string(val, msg)
	wraptest(type(val) == "string",
	msg,
 string.format
   	 "Expected type string but got %s",
   	type(val)))
end

---Test that val is not a string.
function m.assert_not_string(val, msg)
	wraptest(type(val) ~= "string", msg, string.format("Expected type other than string but got %s",
	type(val)))
end

---Test that val is a table.
function m.assert_table(val, msg)
	wraptest(type(val) == "table", msg, string.format("Expected type table but got %s",
	type(val)))
end

---Test that val is not a table.
function m.assert_not_table(val, msg)
	wraptest(type(val) ~= "table", msg, string.format("Expected type other than table but got %s",
	type(val)))
end

---Test that val is a function.
function m.assert_function(val, msg)
	wraptest(type(val) == "function", msg, string.format("Expected type function but got %s",
	type(val)))
end

---Test that val is not a function.
function m.assert_not_function(val, msg)
	wraptest(type(val) ~= "function", msg, string.format("Expected type other than function but got %s",
	type(val)))
end

---Test that val is a thread (coroutine).
function m.assert_thread(val, msg)
	wraptest(type(val) == "thread", msg, string.format("Expected type thread but got %s",
	type(val)))
end

---Test that val is not a thread (coroutine).
function m.assert_not_thread(val, msg)
	wraptest(type(val) ~= "thread", msg, string.format("Expected type other than thread but got %s",
	type(val)))
end

---Test that val is a userdata (light or heavy).
function m.assert_userdata(val, msg)
	wraptest(type(val) == "userdata", msg, string.format("Expected type userdata but got %s",
	type(val)))
end

---Test that val is not a userdata (light or heavy).
function m.assert_not_userdata(val, msg)
	wraptest(type(val) ~= "userdata", msg, string.format("Expected type other than userdata but got %s",
	type(val)))
end

---Test that a value has the expected metatable.
function m.assert_metatable(exp, val, msg)
	local mt = getmetatable(val)
	wraptest(mt == exp, msg, string.format("Expected metatable %s but got %s",
                      	tostring(exp), tostring(mt)))
end

---Test that a value does not have a given metatable.
function m.assert_not_metatable(exp, val, msg)
	local mt = getmetatable(val)
	wraptest(mt ~= exp, msg, string.format("Expected metatable other than %s",
                      	tostring(exp)))
end

---Test that the function raises an error when called.
function m.assert_error(f, msg)
	local ok, err = pcall(f)
	local got = ok or err
	wraptest(not ok, msg,
            { exp="an error", got=got,
           	reason=string.format("Expected an error, got %s", tostring(got)))
end



return m