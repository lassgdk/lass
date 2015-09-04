geometry = require "lass.geometry"

local geometrytest = {}

geometrytest.tests={
	"testTransformCreation",
	"testTransformCreationWithTransform",
	"testGlobalRectangle",
	"testCircleCreation",
	"testRectangleCreation",
	"testCircleCreationWithVectors",
	"testRectangleCreationWithVectors",
	"testVector2Creation",
	"testVector3Creation",
	"testVector2CreationWithVectors",
	"testVector3CreationWithVectors",
	"testIntersectingCirclesAndVectors",
	"testCircleWithRadiusZero",
	"testIntersectingRectanglesAndVectors",
	"testIntersectingRectangleAndCircle",
	"testIntersectingPolygonsAndVectors",
	"testIntersectingPolygonAndCircle",
	"testIntersectingPolygons",
}

function geometrytest.testTransformCreation()

	--[[incorrect creation attempts]]
	assert(pcall(geometry.Transform, 5) ~= true, "improperly created a transform with a number for position")
	assert(pcall(geometry.Transform, nil, nil, 5) ~= true, "improperly created a transform with a number for size")

	assert(pcall(geometry.Transform, "") ~= true, "improperly created a transform with a string for position")
	assert(pcall(geometry.Transform, nil, "") ~= true, "improperly created a transform with a string for rotation")
	assert(pcall(geometry.Transform, nil, nil, "") ~= true, "improperly created a transform with a string for size")

	assert(pcall(geometry.Transform, false) ~= true, "improperly created a transform with false for position")
	assert(pcall(geometry.Transform, nil, false) ~= true, "improperly created a transform with false for rotation")
	assert(pcall(geometry.Transform, nil, nil, false) ~= true, "improperly created a transform with false for size")

	assert(pcall(geometry.Transform, nil, math.huge) ~= true, "improperly allowed infinity for rotation")
	assert(pcall(geometry.Transform, nil, -math.huge) ~= true, "improperly allowed negative infinity for rotation")
	assert(pcall(geometry.Transform, nil, math.huge / math.huge) ~= true, "improperly allowed NaN for rotation")


	--[[strings incorrectly nested in tables]]
	assert(pcall(geometry.Transform, {x = ""}) ~= true, "improperly created a transform with a string for position.x")
	assert(pcall(geometry.Transform, {y = ""}) ~= true, "improperly created a transform with a string for position.y")
	assert(pcall(geometry.Transform, {z = ""}) ~= true, "improperly created a transform with a string for position.z")

	assert(pcall(geometry.Transform, nil, nil, {x = ""}) ~= true, "improperly created a transform with a string for size.x")
	assert(pcall(geometry.Transform, nil, nil, {y = ""}) ~= true, "improperly created a transform with a string for size.y")
	assert(pcall(geometry.Transform, nil, nil, {z = ""}) ~= true, "improperly created a transform with a string for size.z")


	--[[basic creation]]
	local t = geometry.Transform()

	assert(t.position.x == 0, "transform x position didn't default to 0")
	assert(t.position.y == 0, "transform y position didn't default to 0")
	assert(t.position.z == 0, "transform z position didn't default to 0")

	assert(t.rotation == 0, "transform rotation didn't default to 0")

	assert(t.size.x == 1, "transform x size didn't default to 1")
	assert(t.size.y == 1, "transform y size didn't default to 1")
	assert(t.size.z == 1, "transform z size didn't default to 1")


	--[[testing position]]
	t = geometry.Transform({})
	assert(t.position.x == 0, "transform x position didn't default to 0")
	assert(t.position.y == 0, "transform y position didn't default to 0")
	assert(t.position.z == 0, "transform z position didn't default to 0")

	-- values in table should be ignored
	t = geometry.Transform({1, 1, 1})
	assert(t.position.x == 0, "transform x position didn't default to 0")
	assert(t.position.y == 0, "transform y position didn't default to 0")
	assert(t.position.z == 0, "transform z position didn't default to 0")

	t = geometry.Transform({x = 1, y = 1, z = 1})
	assert(t.position.x == 1, "transform x position changed from given value of 1")
	assert(t.position.y == 1, "transform y position changed from given value of 1")
	assert(t.position.z == 1, "transform z position changed from given value of 1")


	--[[testing rotation]]
	t = geometry.Transform(nil, 0)
	assert(t.rotation == 0, "transform rotation changed from given value of 0")
	t = geometry.Transform(nil, 1)
	assert(t.rotation == 1, "transform rotation changed from given value of 1")
	t = geometry.Transform(nil, 359)
	assert(t.rotation == 359, "transform rotation changed from given value of 359")
	t = geometry.Transform(nil, 360)
	assert(t.rotation == 0, "transform rotation should have changed from 360 to 0")
	t = geometry.Transform(nil, 361)
	assert(t.rotation == 1, "transform rotation should have changed from 361 to 1")
	t = geometry.Transform(nil, -1)
	assert(t.rotation == 359, "transform rotation should have changed from -1 to 359")


	--[[testing size]]
	t = geometry.Transform(nil, nil, {})
	assert(t.size.x == 1, "transform x size didn't default to 1")
	assert(t.size.y == 1, "transform y size didn't default to 1")
	assert(t.size.z == 1, "transform z size didn't default to 1")

	-- values in table should be ignored
	t = geometry.Transform(nil, nil, {1, 1, 1})
	assert(t.size.x == 1, "transform x size didn't default to 1")
	assert(t.size.y == 1, "transform y size didn't default to 1")
	assert(t.size.z == 1, "transform z size didn't default to 1")

	t = geometry.Transform(nil, nil, {x = 2, y = 2, z = 2})
	assert(t.size.x == 2, "transform x size changed from given value of 2")
	assert(t.size.y == 2, "transform y size changed from given value of 2")
	assert(t.size.z == 2, "transform z size changed from given value of 2")

	t = geometry.Transform(nil, nil, {x = 2})
	assert(t.size.x == 2, "transform x size changed from given value of 2")
	assert(t.size.y == 1, "transform y size didn't default to 1")
	assert(t.size.z == 1, "transform z size didn't default to 1")

	t = geometry.Transform(nil, nil, {y = 2})
	assert(t.size.x == 1, "transform x size didn't default to 1")
	assert(t.size.y == 2, "transform y size changed from given value of 2")
	assert(t.size.z == 1, "transform z size didn't default to 1")

	t = geometry.Transform(nil, nil, {z = 2})
	assert(t.size.x == 1, "transform x size didn't default to 1")
	assert(t.size.y == 1, "transform y size didn't default to 1")
	assert(t.size.z == 2, "transform z size changed from given value of 2")

end

function geometrytest.testTransformCreationWithTransform()

	--[[incorrect creation attempts]]

	local t1 = geometry.Transform()
	t1.position.x = ""
	assert(pcall(geometry.Transform, t1) ~= true, "improperly made transform with transform with incorrect values")
	t1 = geometry.Transform()
	t1.position.y = ""
	assert(pcall(geometry.Transform, t1) ~= true, "improperly made transform with transform with incorrect values")
	t1 = geometry.Transform()
	t1.position.z = ""
	assert(pcall(geometry.Transform, t1) ~= true, "improperly made transform with transform with incorrect values")

	t1 = geometry.Transform()
	t1.rotation = ""
	assert(pcall(geometry.Transform, t1) ~= true, "improperly made transform with transform with incorrect values")

	t1 = geometry.Transform()
	t1.size.x = ""
	assert(pcall(geometry.Transform, t1) ~= true, "improperly made transform with transform with incorrect values")
	t1 = geometry.Transform()
	t1.size.y = ""
	assert(pcall(geometry.Transform, t1) ~= true, "improperly made transform with transform with incorrect values")
	t1 = geometry.Transform()
	t1.size.z = ""
	assert(pcall(geometry.Transform, t1) ~= true, "improperly made transform with transform with incorrect values")


	--[[basic creation]]
	t1 = geometry.Transform()
	local t2 = geometry.Transform(t1)

	assert(t2.position.x == 0, "transform x position didn't default to 0")
	assert(t2.position.y == 0, "transform y position didn't default to 0")
	assert(t2.position.z == 0, "transform z position didn't default to 0")

	assert(t2.rotation == 0, "transform rotation didn't default to 0")

	assert(t2.size.x == 1, "transform x size didn't default to 1")
	assert(t2.size.y == 1, "transform y size didn't default to 1")
	assert(t2.size.z == 1, "transform z size didn't default to 1")


	--[[basic unpacking]]
	t1 = geometry.Transform(geometry.Vector3(1, 1, 1), 1, geometry.Vector3(2, 2, 2))
	t2 = geometry.Transform(t1)

	assert(t2.position.x == 1, "transform x position changed from given value of 1")
	assert(t2.position.y == 1, "transform y position changed from given value of 1")
	assert(t2.position.y == 1, "transform y position changed from given value of 1")

	assert(t2.rotation == 1, "transform rotation changed from given value of 1")

	assert(t2.size.x == 2, "transform x size changed from given value of 2")
	assert(t2.size.y == 2, "transform y size changed from given value of 2")
	assert(t2.size.y == 2, "transform y size changed from given value of 2")


	--[[alt signature reliance]]

	t1 = geometry.Transform(nil, 1, geometry.Vector3(2, 2, 2))
	-- rotation and size should be overwritten by t1.rotation and .size
	t2 = geometry.Transform(t1, 5, geometry.Vector3(5, 5, 5))
	assert(t2.rotation == 1, "rotation wasn't overwritten by given transform")
	assert(t2.size.x == 2, "x size wasn't overwritten by given transform")
	assert(t2.size.y == 2, "y size wasn't overwritten by given transform")
	assert(t2.size.z == 2, "z size wasn't overwritten by given transform")

	t1 = geometry.Transform(nil, 1, geometry.Vector3(2, 2, 2))
	-- this call shouldn't fail even though the given rotation is improper
	geometry.Transform(t1, "")
	-- ditto for size
	geometry.Transform(t1, nil, "")

end

function geometrytest.testGlobalRectangle()


end

function geometrytest.testCircleCreation()

	--[[incorrect creation attempts]]
	assert(pcall(geometrytest.Circle) ~= true, "circle incorrectly created with no arguments")
	assert(pcall(geometrytest.Circle, -1) ~= true, "circle incorrectly created with -1 radius")
	assert(pcall(geometrytest.Circle, "1") ~= true, "circle incorrectly created with a string for radius")
	assert(pcall(geometrytest.Circle, false) ~= true, "circle incorrectly created with false for radius")

	--[[verify boundary conditions for size]]
	local c = geometry.Circle(0)
	assert(c.radius == 0, "circle radius of 0 should be possible")

	--[[basic creation]]
	c = geometry.Circle(1)

	assert(type(c.radius) == "number", "circle radius is not a number")
	assert(c.radius == 1, "circle radius changed from given value of 1")
	assert(c.position:instanceof(geometry.Vector2), "circle position is not Vector2")
	assert(c.position.x == 0, "circle default x position is not 0")
	assert(c.position.y == 0, "circle default y position is not 0")


	--[[creation with Vector2]]
	c = geometry.Circle(1, geometry.Vector2(0, 0))

	assert(type(c.radius) == "number", "circle radius is not a number")
	assert(c.radius == 1, "circle radius changed from given value of 1")
	assert(c.position:instanceof(geometry.Vector2), "circle position is not Vector2")
	assert(c.position.x == 0, "circle x position changed from given value of 0")
	assert(c.position.y == 0, "circle y position changed from given value of 0")

	c = geometry.Circle(1, geometry.Vector2(1, 1))
	assert(c.position.x == 1, "circle x position changed from given value of 1")
	assert(c.position.y == 1, "circle y position changed from given value of 1")

	c = geometry.Circle(1, geometry.Vector2(-1, -1))
	assert(c.position.x == -1, "circle x position changed from given value of -1")
	assert(c.position.y == -1, "circle y position changed from given value of -1")


	--[[creation with infinity]]
	c = geometry.Circle(math.huge, geometry.Vector2(math.huge, math.huge))
	assert(c.radius == math.huge, "circle radius changed from given value of math.huge")
	assert(c.position.x == math.huge, "circle x position changed from given value of math.huge")
	assert(c.position.y == math.huge, "circle y position changed from given value of math.huge")

end


function geometrytest.testRectangleCreation()

	--[[incorrect creation attempts]]
	assert(pcall(geometry.Rectangle) ~= true, "rectangle incorrectly created with no arguments")
	assert(pcall(geometry.Rectangle, 0) ~= true, "rectangle incorrectly created with only one argument")

	assert(pcall(geometry.Rectangle, -1, 1) ~= true, "rectangle incorrectly created with -1 width")
	assert(pcall(geometry.Rectangle, 1, -1) ~= true, "rectangle incorrectly created with -1 height")

	assert(pcall(geometry.Rectangle, "1", 1) ~= true, "rectangle incorrectly created with a stright for width")
	assert(pcall(geometry.Rectangle, 1, "1") ~= true, "rectangle incorrectly created with a stright for height")

	assert(pcall(geometry.Rectangle, false, 1) ~= true, "rectangle incorrectly created with false for width")
	assert(pcall(geometry.Rectangle, 1, false) ~= true, "rectangle incorrectly created with false for height")


	--[[verify boundary conditions for size]]
	local r = geometry.Rectangle(0, 0)
	assert(r.width == 0, "rectangle width of 0 should be possible")
	assert(r.height == 0, "rectangle height of 0 should be possible")


	--[[basic creation]]
	r = geometry.Rectangle(1, 1)

	assert(type(r.width) == "number", "rectangle width is not a number")
	assert(type(r.height) == "number", "rectangle height is not a number")
	assert(r.width == 1, "rectangle width changed from given value of 1")
	assert(r.height == 1, "rectangle height changed from given value of 1")

	assert(r.position:instanceof(geometry.Vector2), "rectangle position is not Vector2")
	assert(r.position.x == 0, "rectangle default x position is not 0")
	assert(r.position.y == 0, "rectangle default y position is not 0")


	--[[creation with Vector2]]
	r = geometry.Rectangle(1, 1, geometry.Vector2(0, 0))

	assert(type(r.width) == "number", "rectangle width is not a number")
	assert(type(r.height) == "number", "rectangle height is not a number")
	assert(r.width == 1, "rectangle width changed from given value of 1")
	assert(r.height == 1, "rectangle height changed from given value of 1")

	assert(r.position:instanceof(geometry.Vector2), "rectangle position is not Vector2")
	assert(r.position.x == 0, "rectangle x position changed from given value of 0")
	assert(r.position.y == 0, "rectangle y position changed from given value of 0")

	r = geometry.Rectangle(1, 1, geometry.Vector2(1, 1))
	assert(r.position.x == 1, "rectangle x position changed from given value of 1")
	assert(r.position.y == 1, "rectangle y position changed from given value of 1")

	r = geometry.Rectangle(1, 1, geometry.Vector2(-1, -1))
	assert(r.position.x == -1, "rectangle x position changed from given value of -1")
	assert(r.position.y == -1, "rectangle y position changed from given value of -1")


	--[[creation with infinity]]
	r = geometry.Rectangle(math.huge, math.huge, geometry.Vector2(math.huge, math.huge))
	assert(r.width == math.huge, "rectangle width changed from given value of math.huge")
	assert(r.height == math.huge, "rectangle height changed from given value of math.huge")
	assert(r.position.x == math.huge, "rectangle x position changed from given value of math.huge")
	assert(r.position.y == math.huge, "rectangle y position changed from given value of math.huge")

end

function geometrytest.testCircleCreationWithVectors()
	-- extended testing with Vectors in weird ways

	local v = geometry.Vector3()
	local c = geometry.Circle(1, v)

	assert(c.position:instanceof(geometry.Vector2), "circle position should be Vector2")
	assert(c.position:instanceof(geometry.Vector3) == false, "circle position shouldn't be Vector3")
	assert(c.position.x == 0, "circle default x position is not 0")
	assert(c.position.y == 0, "circle default y position is not 0")
	assert(c.position.z == nil, "circle z position shouldn't exist")

	v = geometry.Vector2(geometry.Vector3(1, 1))
	c = geometry.Circle(1, v)

	assert(c.position:instanceof(geometry.Vector2), "circle position should be Vector2")
	assert(c.position:instanceof(geometry.Vector3) == false, "circle position shouldn't be Vector3")
	assert(c.position.x == 1, "circle x position changed from given value of 1")
	assert(c.position.y == 1, "circle y position changed from given value of 1")
	assert(c.position.z == nil, "circle z position shouldn't exist")

	v = geometry.Vector2(geometry.Vector3(1, 1, 1))
	c = geometry.Circle(1, v)

	assert(c.position:instanceof(geometry.Vector2), "circle position should be Vector2")
	assert(c.position:instanceof(geometry.Vector3) == false, "circle position shouldn't be Vector3")
	assert(c.position.x == 1, "circle x position changed from given value of 1")
	assert(c.position.y == 1, "circle y position changed from given value of 1")
	assert(c.position.z == nil, "circle z position shouldn't exist")

	v = geometry.Vector3(geometry.Vector2(1, 1))
	c = geometry.Circle(1, v)

	assert(c.position:instanceof(geometry.Vector2), "circle position should be Vector2")
	assert(c.position:instanceof(geometry.Vector3) == false, "circle position shouldn't be Vector3")
	assert(c.position.x == 1, "circle x position changed from given value of 1")
	assert(c.position.y == 1, "circle y position changed from given value of 1")
	assert(c.position.z == nil, "circle z position shouldn't exist")

end

function geometrytest.testRectangleCreationWithVectors()
	-- extended testing with Vectors in weird ways

	local v = geometry.Vector3()
	r = geometry.Rectangle(1, 1, v)

	assert(r.position:instanceof(geometry.Vector2), "rectangle position should be Vector2")
	assert(r.position:instanceof(geometry.Vector3) == false, "rectangle position shouldn't be Vector3")
	assert(r.position.x == 0, "rectangle default x position is not 0")
	assert(r.position.y == 0, "rectangle default y position is not 0")
	assert(r.position.z == nil, "rectangle z position shouldn't exist")

	v = geometry.Vector2(geometry.Vector3(1, 1))
	r = geometry.Rectangle(1, 1, v)

	assert(r.position:instanceof(geometry.Vector2), "rectangle position should be Vector2")
	assert(r.position:instanceof(geometry.Vector3) == false, "rectangle position shouldn't be Vector3")
	assert(r.position.x == 1, "rectangle x position changed from given value of 1")
	assert(r.position.y == 1, "rectangle y position changed from given value of 1")
	assert(r.position.z == nil, "rectangle z position shouldn't exist")

	v = geometry.Vector2(geometry.Vector3(1, 1, 1))
	r = geometry.Rectangle(1, 1, v)

	assert(r.position:instanceof(geometry.Vector2), "rectangle position should be Vector2")
	assert(r.position:instanceof(geometry.Vector3) == false, "rectangle position shouldn't be Vector3")
	assert(r.position.x == 1, "rectangle x position changed from given value of 1")
	assert(r.position.y == 1, "rectangle y position changed from given value of 1")
	assert(r.position.z == nil, "rectangle z position shouldn't exist")

	v = geometry.Vector3(geometry.Vector2(1, 1))
	r = geometry.Rectangle(1, 1, v)

	assert(r.position:instanceof(geometry.Vector2), "rectangle position should be Vector2")
	assert(r.position:instanceof(geometry.Vector3) == false, "rectangle position shouldn't be Vector3")
	assert(r.position.x == 1, "rectangle x position changed from given value of 1")
	assert(r.position.y == 1, "rectangle y position changed from given value of 1")
	assert(r.position.z == nil, "rectangle z position shouldn't exist")

end

function geometrytest.testVector2Creation()

	--[[incorrect creation attempts]]
	assert(pcall(geometry.Vector2, "") ~= true, "incorrectly created Vector2 with a string for x")
	assert(pcall(geometry.Vector2, 0, "") ~= true, "incorrectly created Vector2 with a string for y")

	assert(pcall(geometry.Vector2, false) ~= true, "incorrectly created Vector2 with false for x")
	assert(pcall(geometry.Vector2, 0, false) ~= true, "incorrectly created Vector2 with false for y")


	--[[purely default creation]]
	local v = geometry.Vector2()
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == nil, "Vector2 shouldn't have a z value")
	assert(v:instanceof(geometry.Vector2), "Vector2 should be valid as a Vector2")


	--[[creation with just numbers]]
	v = geometry.Vector2(1)
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 0, "Vector2 y value didn't default to 0")

	v = geometry.Vector2(1, 1)
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")

	v = geometry.Vector2(1, 1, 1)
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")
	assert(v.z == nil, "Vector2 shouldn't have a z value")


	--[[creation with infinity]]
	v = geometry.Vector2(math.huge, math.huge)
	assert(v.x == math.huge, "Vector2 x value changed from math.huge")
	assert(v.y == math.huge, "Vector2 y value changed from math.huge")


	--[[creation with just tables]]
	v = geometry.Vector2({})
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")

	-- values given here should be ignored
	v = geometry.Vector2({1, 1})
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")

	v = geometry.Vector2({x = 1, y = 1})
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")
	
	-- second table should be ignored
	v = geometry.Vector2({}, {x = 1, y = 1})
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")


	--[[creation with tables and numbers]]
	-- second value should be ignored
	v = geometry.Vector2({}, 1)
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")

	assert(pcall(geometry.Vector2, 1, {}) ~= true, "incorrectly created Vector2 with a table for y")

end

function geometrytest.testVector3Creation()

	--[[incorrect creation attempts]]
	assert(pcall(geometry.Vector3, "") ~= true, "incorrectly created Vector3 with a string for x")
	assert(pcall(geometry.Vector3, 0, "") ~= true, "incorrectly created Vector3 with a string for y")
	assert(pcall(geometry.Vector3, 0, 0, "") ~= true, "incorrectly created Vector3 with a string for z")

	assert(pcall(geometry.Vector3, false) ~= true, "incorrectly created Vector3 with false for x")
	assert(pcall(geometry.Vector3, 0, false) ~= true, "incorrectly created Vector3 with false for y")
	assert(pcall(geometry.Vector3, 0, 0, false) ~= true, "incorrectly created Vector3 with false for z")


	--[[purely default creation]]
	local v = geometry.Vector3()
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")
	assert(v:instanceof(geometry.Vector3), "Vector3 should be valid as a Vector3")


	--[[creation with just numbers]]
	v = geometry.Vector3(1)
	assert(v.x == 1, "Vector3 x value changed from 1")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")

	v = geometry.Vector3(1, 1)
	assert(v.x == 1, "Vector3 x value changed from 1")
	assert(v.y == 1, "Vector3 y value changed from 1")
	assert(v.z == 0, "Vector3 z value didn't default to 0")

	v = geometry.Vector3(1, 1, 1)
	assert(v.x == 1, "Vector3 x value changed from 1")
	assert(v.y == 1, "Vector3 y value changed from 1")
	assert(v.z == 1, "Vector3 z value changed from 1")
	

	--[[creation with infinity]]
	v = geometry.Vector3(math.huge, math.huge, math.huge)
	assert(v.x == math.huge, "Vector3 x value changed from math.huge")
	assert(v.y == math.huge, "Vector3 y value changed from math.huge")
	assert(v.z == math.huge, "Vector3 z value changed from math.huge")


	--[[creation with just tables]]
	v = geometry.Vector3({})
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")

	-- values here should be ignored
	v = geometry.Vector3({1, 1, 1})
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")

	v = geometry.Vector3({x = 1, y = 1, z = 1})
	assert(v.x == 1, "Vector3 x value changed from 1")
	assert(v.y == 1, "Vector3 y value changed from 1")
	assert(v.z == 1, "Vector3 z value changed from 1")

	-- second table should be ignored
	v = geometry.Vector3({}, {x = 1, y = 1, z = 1})
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")


	--[[creation with tables and numbers]]
	-- second and third values should be ignored
	v = geometry.Vector3({}, 1, 1)
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")

	assert(pcall(geometry.Vector3, 1, {}) ~= true, "incorrectly created Vector3 with a table for y")
	assert(pcall(geometry.Vector3, 1, 1, {}) ~= true, "incorrectly created Vector3 with a table for z")

end

function geometrytest.testVector2CreationWithVectors()

	--[[creation with Vector2]]
	local v = geometry.Vector2(geometry.Vector2())
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v:instanceof(geometry.Vector2), "Vector2 should be valid as a Vector2")

	v = geometry.Vector2(geometry.Vector2(1, 1))
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")

	local v2 = geometry.Vector2(1, 1)
	v = geometry.Vector2(v2.x, v2.y)
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")

	v = geometry.Vector2(geometry.Vector2(), geometry.Vector2(1, 1))
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")


	--[[creation with Vector3]]
	v = geometry.Vector2(geometry.Vector3())
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == nil, "Vector2 shouldn't have a z value")
	assert(v:instanceof(geometry.Vector2), "Vector2 should be valid as a Vector2")
	assert(v:instanceof(geometry.Vector3) == false, "Vector2 shouldn't be valid as a Vector3")

	v = geometry.Vector2(geometry.Vector3(1, 1, 1))
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")
	assert(v.z == nil, "Vector2 shouldn't have a z value")

	local v3 = geometry.Vector3(1, 1, 1)
	v = geometry.Vector2(v3.x, v3.y, v3.z)
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")
	assert(v.z == nil, "Vector2 shouldn't have a z value")

	v = geometry.Vector2(geometry.Vector3(), geometry.Vector3(1, 1, 1))
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == nil, "Vector2 shouldn't have a z value")

end

function geometrytest.testVector3CreationWithVectors()

	--[[creation with Vector2]]
	local v = geometry.Vector3(geometry.Vector2())
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")
	assert(v:instanceof(geometry.Vector2), "Vector3 should be valid as a Vector2")
	assert(v:instanceof(geometry.Vector3), "Vector3 should be valid as a Vector3")

	v = geometry.Vector3(geometry.Vector2(1, 1))
	assert(v.x == 1, "Vector3 x value changed from 1")
	assert(v.y == 1, "Vector3 y value changed from 1")
	assert(v.z == 0, "Vector3 z value didn't default to 0")

	local v2 = geometry.Vector2(1, 1)
	v = geometry.Vector3(v2.x, v2.y)
	assert(v.x == 1, "Vector3 x value changed from 1")
	assert(v.y == 1, "Vector3 y value changed from 1")
	assert(v.z == 0, "Vector3 z value didn't default to 0")

	v = geometry.Vector3(geometry.Vector2(), geometry.Vector2(1, 1))
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")


	--[[creation with Vector3]]
	v = geometry.Vector3(geometry.Vector3())
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")
	assert(v:instanceof(geometry.Vector2), "Vector3 should be valid as a Vector2")
	assert(v:instanceof(geometry.Vector3), "Vector3 shouldn't be valid as a Vector3")

	v = geometry.Vector3(geometry.Vector3(1, 1, 1))
	assert(v.x == 1, "Vector3 x value changed from 1")
	assert(v.y == 1, "Vector3 y value changed from 1")
	assert(v.z == 1, "Vector3 z value changed from 1")

	local v3 = geometry.Vector3(1, 1, 1)
	v = geometry.Vector3(v3.x, v3.y, v3.z)
	assert(v.x == 1, "Vector3 x value changed from 1")
	assert(v.y == 1, "Vector3 y value changed from 1")
	assert(v.z == 1, "Vector3 z value changed from 1")

	v = geometry.Vector3(geometry.Vector3(), geometry.Vector3(1, 1, 1))
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")

end

function geometrytest.testIntersectingCirclesAndVectors()
	local c1, c2 = geometry.Circle(3), geometry.Circle(1)
	local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(4,0))

	assert(geometry.intersecting(c1, c2), "circles at same position aren't intersecting")
	assert(geometry.intersecting(c2, c1), "circles at same position aren't intersecting")
	assert(geometry.intersecting(c1, c2, t1, t2), "circle edges should be touching")
	assert(geometry.intersecting(c2, c1, t2, t1), "circle edges should be touching")
	t2.position.x = 4.0001
	assert(not geometry.intersecting(c1, c2, t1, t2), "circle edges should not be touching")

	local v = geometry.Vector2(1,1)
	assert(geometry.intersecting(c1, v), "circle should contain vector")
end

function geometrytest.testCircleWithRadiusZero()
	local c1, c2 = geometry.Circle(0), geometry.Circle(1)
	local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(4,0))

	assert(geometry.intersecting(c1, c2), "circles at same position aren't intersecting")
	assert(not geometry.intersecting(c1, c2, t1, t2), "circles should not be intersecting")

	local v = geometry.Vector2(0,0)
	assert(geometry.intersecting(c1, v), "circle should contain vector")
	v.x = 0.0001
	assert(not geometry.intersecting(c1, v), "circle should not contain vector")
end

function geometrytest.testIntersectingRectanglesAndVectors()
	local r1, r2 = geometry.Rectangle(1,2), geometry.Rectangle(1,3)
	local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(0,0))
	local colliding, data

	assert(geometry.intersecting(r1, r2), "rectangles at same position aren't intersecting")
	assert(geometry.intersecting(r1, r2, t1, t2, true, true), "rectangles at same position aren't intersecting")


	t2.position.y = 2.5
	colliding, data = geometry.intersecting(r1, r2, t1, t2, true, true)
	assert(colliding and data.shortestOverlap == 0, "rectangles should be touching with overlap of 0")

	t2.position.y = 2.50001
	colliding, data = geometry.intersecting(r1, r2, t1, t2, true, true)
	assert(not colliding, "rectangles should not be touching")

	t2.position.y = 1.5
	colliding, data = geometry.intersecting(r1, r2, t1, t2, true, true)
	assert(colliding and data.shortestOverlap == 1, "rectangles should be touching with overlap of 1")

	assert(geometry.intersecting(r1, geometry.Vector2(0.5, -1)), "rectangle should contain vector")
	assert(not geometry.intersecting(r1, geometry.Vector2(0.5, 1.01)), "rectangle should not contain vector")
end

function geometrytest.testIntersectingRectangleAndCircle()
	local rec, cir = geometry.Rectangle(1,2), geometry.Circle(3)
	local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(0,0))

	assert(geometry.intersecting(rec, cir), "figures at same origin aren't intersecting")

	t2.position.x = 3.5
	assert(geometry.intersecting(rec, cir, t1, t2), "figures should be touching")
	t2.position.x = 4.001
	assert(not geometry.intersecting(rec, cir, t1, t2), "figures should not be touching")
end

function geometrytest.testIntersectingPolygonsAndVectors()
	local p1 = geometry.Polygon({-100, -50, 100, -50, 0, 50})
	local p2 = geometry.Polygon({-10, -5, 10, -5, 0, 5})
	local t1 = geometry.Transform(geometry.Vector3(0,0))
	local t2 = geometry.Transform(geometry.Vector3(0,0))

	assert(geometry.intersecting(p1, p2), "polygons at same origin aren't intersecting")
	assert(geometry.intersecting(p1, p2, t1, t2), "polygons at same origin aren't intersecting")

	p2 = geometry.Polygon(p1.vertices)
	t2.position.x = 200
	assert(geometry.intersecting(p1, p2, t1, t2), "polygons should be touching")
	t2.position.x = 200.001
	assert(not geometry.intersecting(p1, p2, t1, t2), "polygons should not be touching")

	assert(geometry.intersecting(p1, geometry.Vector2(0,0)), "polygon should contain vector")
	assert(geometry.intersecting(geometry.Vector2(0,0), p1), "polygon should contain vector")
	assert(p1:globalPolygon(t1):contains(geometry.Vector2(0,0)), "polygon should contain vector")

	assert(geometry.intersecting(p1, geometry.Vector2(100,-50)), "polygon should contain vector")
	assert(geometry.intersecting(geometry.Vector2(100,-50), p1), "polygon should contain vector")
	assert(p1:globalPolygon(t1):contains(geometry.Vector2(100,-50)), "polygon should contain vector")

	assert(not geometry.intersecting(p1, geometry.Vector2(100,-50.0001)), "polygon should not contain vector")
	assert(not geometry.intersecting(geometry.Vector2(100,-50.0001), p1), "polygon should not contain vector")
	assert(not p1:globalPolygon(t1):contains(geometry.Vector2(100,-50.0001)), "polygon should not contain vector")
end

function geometrytest.testIntersectingPolygonAndCircle()

	local pol = geometry.Rectangle(10,3):toPolygon()
	local cir = geometry.Circle(2)
	local t1 = geometry.Transform(geometry.Vector3(0,0))
	local t2 = geometry.Transform(geometry.Vector3(0,0))
	local r, d

	assert(geometry.intersecting(pol, cir), "figures at same origin aren't intersecting")
	assert(geometry.intersecting(pol, cir, t1, t2), "figures at same origin aren't intersecting")
	t1.position.x = 0.01
	assert(geometry.intersecting(pol, cir, t1, t2), "figures should be intersecting")

	t1.position.x = 0
	t2.position.x = 7
	assert(geometry.intersecting(pol, cir, t1, t2), "figures should be intersecting")
	assert(geometry.intersecting(cir, pol, t2, t1), "figures should be intersecting")
	t2.position.x = 7.001
	assert(not geometry.intersecting(pol, cir, t1, t2), "figures should not be intersecting")
	assert(not geometry.intersecting(cir, pol, t2, t1), "figures should not be intersecting")

	pol = geometry.Polygon({{x=-100, y=-50}, {x=100, y=-50}, {x=0, y=50}})
	t2.position.x = 102
	t2.position.y = -50

	assert(geometry.intersecting(pol, cir, t1), "figures should be intersecting")
	assert(geometry.intersecting(cir, pol, t2, t1), "figures should be intersecting")


	t2.position.x = 102.001
	assert(not geometry.intersecting(pol, cir, t1, t2), "figures should not be intersecting")
	assert(not geometry.intersecting(cir, pol, t2, t1), "figures should not be intersecting")

	pol = geometry.Polygon({{x=0, y=0}, {x=25, y=-25}, {x=0, y=-50}, {x=-25, y=-25}})
	cir.radius = 25

	t1.position.x = 0
	t1.position.y = 0
	t2.position.x = 0
	t2.position.y = 25.0001
	assert(not geometry.intersecting(pol, cir, t1, t2), "figures should not be intersecting")

	t2.position.y = 25
	r, d = geometry.intersecting(pol, cir, t1, t2)
	assert(r and d.shortestOverlap == 0, "figures should be intersecting with overlap of 0")

	t2.position.y = 0
	r, d = geometry.intersecting(pol, cir, t1, t2)
	assert(r and d.shortestOverlap == cir.radius, "figures should be intersecting with overlap of " .. cir.radius)
end

function geometrytest.testPolygonWithNoArguments()

end

function geometrytest.testIntersectingPolygons()
	local p1 = geometry.Polygon({-100, -50, 100, -50, 0, 50})
	local p2 = geometry.Polygon({-100, -50, 100, -50, 0, 50})
	local t1 = geometry.Transform(geometry.Vector3(0,0))
	local t2 = geometry.Transform(geometry.Vector3(100,40))

	assert(geometry.intersecting(p1, p2, t1, t2), "figures should be intersecting")

end

return geometrytest
