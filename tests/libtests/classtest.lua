class = require "lass.class"

function testClassDefine()
	--ensure that defining a base class will work, with or w/o a constructor

	local Animal = class.define()

	print("elements in class Animal (no constructor):")
	for k,v in pairs(Animal) do
		print(k,v)
	end

	Animal = class.define(function(self, legs) self.legs = legs or 4 end)
	print("elements in class Animal (with constructor)")
	for k, v in pairs(Animal) do
		print(k,v)
	end
end

function testClassInheritance()
	--ensure that class inheritance (and self.base) works

	local Animal = class.define(function(self, legs) self.legs = legs or 4 end)
	local Dog = class.define(Animal, function(self, legs, breed)
		self.breed = breed or "unknown"
		self.base.init(self, legs)
	end)

	local pom = Dog(3, "pomeranian")
	assert(pom.legs == 3, "pom.legs should be 3 but is instead " .. tostring(pom.legs))
	assert(pom.breed == "pomeranian", "pom.breed should be 'pomeranian' but is instead " .. pom.breed)
end

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

	local Animal = class.define()
	local a = Animal()

	testMemberAssignment(a, "x", 3)
	a:init()
	assert(a.x ~= nil,
		"class instance 'a' lost member 'x' after instance:init()")

	testMemberAssignment(a, "x", 3)
	Animal.init(a)
	assert(a.x ~= nil,
		"class instance 'a' lost member 'x' after Class.init(instance)")
end

function main()

	testClassDefine()
	testClassInheritance()
	testNilInit()

	print("testing complete with no assertion failures")
end

main()
