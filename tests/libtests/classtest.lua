class = require "lass.class"

function testMemberAssignment(object, varName, varValue)
	--ensure that assignment to an instance member works
	--(this will modify the instance)

	if not varName and varValue then return end

	--did the assignment work at all?
	object[varName] = varValue
	assert(object[varName] ~= nil, "assigning member to class instance failed")

	local repr = ""
	if type(varName) == "string" then
		repr = "object." .. varName
	else
		repr = "object[" .. varName .. "]"
	end

	--did the assignment match what we put in?
	assert(
		object[varName] == varValue,
		repr .. "should be " .. tostring(varValue) .. " but is instead " .. tostring(object[varName])
	)
end

function testNilInit()

	Animal = class.define()
	a = Animal()

	testMemberAssignment(a, "x", 3)
	a:init()
	assert(a.x == nil, "class instance retained member after instance:init()")

	testMemberAssignment(a, "x", 3)
	Animal.init(a)
	assert(a.x == nil, "class instance retained member after Class.init(instance)")
end