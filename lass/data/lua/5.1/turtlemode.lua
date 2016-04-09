local m = {}

local function wraptest(got, msg, reason)

	if got then
		return
	end

	local message
	if msg then
		message = reason .. "\n" .. msg
	else
		message = reason
	end

	-- READ THIS BEFORE EDITING THE CODE BELOW.
	-- this is where things get weird.
	--
	-- messages printed by error/assert always start with the location and line
	-- number of the error/assert call. for the turtlemode assert functions,
	-- this will always come out to something like "turtlemode.lua:40", no
	-- matter where those functions are called from. this is obviously
	-- unhelpful.
	-- 
	-- the problem is that there is no obvious way to change this behaviour.
	-- the location prefix is not part of the traceback message, so overriding
	-- debug.traceback does nothing. we can't write our own error function in
	-- pure lua without calling the original error function.
	--
	-- if we cannot remove the prefix by conventional means, then we must do so
	-- via I/O exploits. if we insert a bunch of backspace characters ('\b')
	-- at the beginning of the error message, the prefix will be erased. we
	-- assume that the number of backspace characters we need can be found by
	-- looking at the location and line number in debug.getinfo(1). 
	--
	-- here is the rub: the debug.getinfo call and the final error call are on
	-- separate lines. that means that the line number we use to figure out
	-- how many backspace characters to write is actually offset by the number
	-- of lines between the debug.getinfo call and the error call.
	--
	-- in other words, lineOffset must be equal to the number of lines between
	-- 'local info=...getinfo(1)' and 'error(backspace...message)' plus 1. IF
	-- YOU ADD OR REMOVE ANY LINES OF CODE IN THAT RANGE, YOU MUST UPDATE
	-- lineOffset ACCORDINGLY.

	local lineOffset = 9

	local info = debug.getinfo(1)
	local newInfo = debug.getinfo(3)
	local prefix = string.format("%s:%s: ", info.short_src, tostring(info.currentline+lineOffset))
	local newPrefix = string.format("%s:%s: ", newInfo.short_src, tostring(newInfo.currentline))

	local backspace = ""
	for i = 1, #prefix do
		backspace = backspace .. "\b"
	end
	error(backspace .. newPrefix .. message)
end

local function startsWith(s, sub)

	return string.find(s, sub) == 1
end

local function endsWith(s, sub)

	return string.find(s, sub, #sub) ~= nil
end

local function gatherTestFiles(dir)

	dir = dir or ""
	local files = {}
	local ext = ".lua"
	local testPrefixOrSuffix = "test"

	if not love.filesystem.isDirectory(dir) then
		error(string.format("'%s' is not a directory", dir))
	end

	for i, v in ipairs(love.filesystem.getDirectoryItems(dir)) do

		local fullName = dir .. "/" .. v

		--only gather files and folders whose names begin or end with "test"
		if startsWith(v, testPrefixOrSuffix) or endsWith(v, testPrefixOrSuffix) then

			--lua files
			if love.filesystem.isFile(fullName) and string.find(v, ext, #ext) then

				files[#files + 1] = fullName
			-- folders
			elseif love.filesystem.isDirectory(fullName) then

				for i2, v2 in ipairs(gatherTestFiles(fullName)) do
					files[#files + 1] = v2
				end
			end
		end
	end

	return files
end

local TestModule = {}

function TestModule:__newindex(key, value)

	if startsWith(key, "test") or endsWith(key, "test") then
		self._testNames[#self._testNames + 1] = key
	end
	rawset(self, key, value)
end

function m.testModule()

	t = {}
	t._testNames = {}
	setmetatable(t, TestModule)
	return t
end

function m.run(scene)

	local loadedModules, loadedModuleNames = {}, {}
	for i, v in ipairs(gatherTestFiles("tests")) do
		loadedModules[#loadedModules + 1] = love.filesystem.load(v)()
		loadedModuleNames[#loadedModuleNames + 1] = v
	end


	for i, loadedModule in ipairs(loadedModules) do
		print("---" .. loadedModuleNames[i] .. "---")
		local testsRun = 0
		local failures = 0

		for j, testName in ipairs(loadedModule._testNames) do

			testsRun = testsRun + 1

			-- scene = lass.GameScene()
			-- scene:loadSettings("settings.lua")
			scene:init()
			local r, d = xpcall(loadedModule[testName], debug.traceback, scene)

			if not r then
				print(testName .. " gave the following error:")

				-- indent the error message
				print("    " .. d:gsub("\n", "\n    "))

				failures = failures + 1
			end
		end

		print("Completed " .. testsRun .. " tests. Assertion failures: " .. failures)
	end

	print("All tests complete")
end

---got == true.
-- (Named "assertTrue" to not conflict with standard assert.)
-- @param msg Message to display with the result.
function m.assertTrue(got, msg)
	wraptest(got, msg, string.format("Expected success, got %s.", tostring(got)))
end

---got == false.
function m.assertFalse(got, msg)
	wraptest(not got, msg, string.format("Expected false, got %s", tostring(got)))
end

--got == nil
function m.assertNil(got, msg)
	wraptest(got == nil, msg, string.format("Expected nil, got %s", tostring(got)))
end

--got ~= nil
function m.assertNotNil(got, msg)
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
function m.assertEqual(exp, got, tol, msg)
	tol, msg = tol_or_msg(tol, msg)
	if type(exp) == "number" and type(got) == "number" then
   		wraptest(
   			math.abs(exp - got) <= tol,
   			msg,
   			string.format("Expected %s +/- %s, got %s", tostring(exp), tostring(tol), tostring(got))
   		)
	else
	   	wraptest(exp == got, msg, string.format("Expected %q, got %q", tostring(exp), tostring(got)))
	end
end

---exp ~= got.
function m.assertNotEqual(exp, got, msg)
	wraptest(exp ~= got,
		msg,
		"Expected something other than " .. tostring(exp)
	)
end

---val > lim.
function m.assertGreater(lim, val, msg)
	wraptest(val > lim,
		msg,
		string.format("Expected a value > %s, got %s",
		tostring(lim), tostring(val))
	)
end

---val >= lim.
function m.assertGreaterOrEqual(lim, val, msg)
	wraptest(
		val >= lim,
		msg,
		string.format("Expected a value >= %s, got %s",
		tostring(lim), tostring(val))
	)
end

---val < lim.
function m.assertLess(lim, val, msg)
	wraptest(
		val < lim,
		msg,
		string.format("Expected a value < %s, got %s",
		tostring(lim), tostring(val))
	)
end

---val <= lim.
function m.assertLessOrEqual(lim, val, msg)
	wraptest(
		val <= lim,
		msg,
		string.format("Expected a value <= %s, got %s",
		tostring(lim), tostring(val))
	)
end

---#val == len.
function m.assertLen(len, val, msg)
	wraptest(
		#val == len,
		msg,
		string.format("Expected #val == %d, was %d",
		len, #val)
	)
end

---#val ~= len.
function m.assertNotLen(len, val, msg)
	wraptest(
		#val ~= len,
		msg,
		string.format("Expected length other than %d", len)
	)
end

---Test that the string s matches the pattern exp.
function m.assertMatch(pat, s, msg)
	s = tostring(s)
	wraptest(
		type(s) == "string" and s:match(pat),
		msg,
		string.format(
			"Expected string to match pattern %s, was %s",
			pat,
			(s:len() > 30 and (s:sub(1,30) .. "...")or s)
		)
	)
end

---Test that the string s doesn't match the pattern exp.
function m.assertNotMatch(pat, s, msg)
	wraptest(
		type(s) ~= "string" or not s:match(pat),
		msg,
		string.format("Should not match pattern %s", pat)
	)
end

---Test that val is a boolean.
function m.assertBoolean(val, msg)
	wraptest(
		type(val) == "boolean",
		msg,
		string.format("Expected type boolean but got %s", type(val))
	)
end

---Test that val is not a boolean.
function m.assertNotBoolean(val, msg)
	wraptest(
		type(val) ~= "boolean",
		msg,
		string.format("Expected type other than boolean but got %s", type(val))
	)
end

---Test that val is a number.
function m.assertNumber(val, msg)
	wraptest(
		type(val) == "number",
		msg,
		string.format("Expected type number but got %s", type(val))
	)
end

---Test that val is not a number.
function m.assertNotNumber(val, msg)
	wraptest(
		type(val) ~= "number",
		msg,
		string.format("Expected type other than number but got %s", type(val))
	)
end

---Test that val is a string.
function m.assertString(val, msg)
	wraptest(
		type(val) == "string",
		msg,
		string.format("Expected type string but got %s", type(val))
	)
end

---Test that val is not a string.
function m.assertNotString(val, msg)
	wraptest(
		type(val) ~= "string",
		msg,
		string.format("Expected type other than string but got %s", type(val))
	)
end

---Test that val is a table.
function m.assertTable(val, msg)
	wraptest(
		type(val) == "table",
		msg,
		string.format("Expected type table but got %s", type(val))
	)
end

---Test that val is not a table.
function m.assertNotTable(val, msg)
	wraptest(
		type(val) ~= "table",
		msg,
		string.format("Expected type other than table but got %s", type(val))
	)
end

---Test that val is a function.
function m.assertFunction(val, msg)
	wraptest(
		type(val) == "function",
		msg,
		string.format("Expected type function but got %s", type(val))
	)
end

---Test that val is not a function.
function m.assertNotFunction(val, msg)
	wraptest(
		type(val) ~= "function",
		msg,
		string.format("Expected type other than function but got %s", type(val))
	)
end

---Test that val is a thread (coroutine).
function m.assertThread(val, msg)
	wraptest(
		type(val) == "thread",
		msg,
		string.format("Expected type thread but got %s", type(val))
	)
end

---Test that val is not a thread (coroutine).
function m.assertNotThread(val, msg)
	wraptest(
		type(val) ~= "thread",
		msg,
		string.format("Expected type other than thread but got %s", type(val))
	)
end

---Test that val is a userdata (light or heavy).
function m.assertUserdata(val, msg)
	wraptest(
		type(val) == "userdata",
		msg,
		string.format("Expected type userdata but got %s", type(val))
	)
end

---Test that val is not a userdata (light or heavy).
function m.assertNotUserdata(val, msg)
	wraptest(
		type(val) ~= "userdata",
		msg,
		string.format("Expected type other than userdata but got %s", type(val))
	)
end

---Test that a value has the expected metatable.
function m.assertMetatable(exp, val, msg)
	local mt = getmetatable(val)
	wraptest(
		mt == exp,
		msg,
		string.format("Expected metatable %s but got %s", tostring(exp), tostring(mt))
	)
end

---Test that a value does not have a given metatable.
function m.assertNotMetatable(exp, val, msg)
	local mt = getmetatable(val)
	wraptest(
		mt ~= exp,
		msg,
		string.format("Expected metatable other than %s", tostring(exp))
	)
end

---Test that the function raises an error when called.
function m.assertError(f, msg)
	local ok, err = pcall(f)
	local got = ok or err
	wraptest(not ok, msg, string.format("Expected an error, got %s", tostring(got)))
end



return m