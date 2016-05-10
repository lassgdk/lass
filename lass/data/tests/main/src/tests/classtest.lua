local class = require "lass.class"
local turtlemode = require("turtlemode")

local classtest = turtlemode.testModule()
local assertEqual = turtlemode.assertEqual
local assertNotEqual = turtlemode.assertNotEqual


local function testMemberAssignment(object, varName, varValue)
	--ensure that assignment to an instance member works
	--(this will modify the instance)

	if not varName and varValue then return end

	--did the assignment work at all?
	object[varName] = varValue
	assertNotEqual(object[varName], nil, "assigning member to class instance failed")

	local repr = ""
	if type(varName) == "string" then
		repr = "object." .. varName
	else
		repr = "object[" .. varName .. "]"
	end

	--did the assignment match what we put in?
	assertEqual(object[varName], varValue)
end

local function testClassDefine(scene)
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

function classtest:testClassInheritance(scene)
	--ensure that class inheritance (and self.__base) works

	local Being = class.define()
	local Animal = class.define(Being, function(self, legs)
		-- print(self.legs)
		-- print(self.__base, self.__base.init, self, self.init)
		-- assert(self.legs ~= 4)

		self.legs = legs or 4
		self.__base.init(self)
	end)
	local Dog = class.define(Animal, function(self, legs, breed)
		self.breed = breed or "unknown"
		self.__base.init(self, legs)
	end)

	local pom = Dog(3, "pomeranian")
	assertEqual(pom.legs, 3)
	assertEqual(pom.breed, "pomeranian")
end

function classtest:testNilInit(scene)

	local Animal = class.define()
	local a = Animal()

	testMemberAssignment(a, "x", 3)
	a:init()
	assertNotEqual(a.x, nil, "class instance 'a' lost member 'x' after instance:init()")

	testMemberAssignment(a, "x", 3)
	Animal.init(a)
	assertNotEqual(a.x, nil, "class instance 'a' lost member 'x' after Class.init(instance)")
end

function classtest:testInstanceOf(scene)

	local Animal = class.define()
	local Dog = class.define(Animal)
	local a = Animal()
	local dog = Dog()

	assert(class.instanceof(a, Animal), "a should be instance of Animal class, but isn't")

	assert(class.instanceof(dog, Dog), "dog should be instance of Dog class, but isn't")
	assert(class.instanceof(dog, Animal), "dog should be instance of Animal super class, but isn't")

	local Plant = class.define()

	assert(class.instanceof(dog, Dog), "dog should be instance of Dog class, but isn't")
	assert(class.instanceof(dog, Dog, Plant), "class.instanceof fails with multiple classes specified")
	assert(class.instanceof(dog, Plant, Dog), "class.instanceof fails with multiple classes specified")
end

return classtest
