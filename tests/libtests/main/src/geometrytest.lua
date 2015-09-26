local geometry = require "lass.geometry"

local geometrytest = {}
local NaN = math.huge / math.huge

geometrytest.tests={
	"assertIncorrectVectorAlgebra",
	"testVector2Add",
	"testVector3Add",
	"testVector2And3Add",
	"testVector2Subtract",
	"testVector3Subtract",
	"testVector2And3Subtract",
	"testVector2Multiply",
	"testVector3Multiply",
	"testVector2Divide",
	"testVector3Divide",
	"testTransformCreation",
	"testTransformCreationWithTransform",
	"testGlobalRectangle", -- placeholder
	"testCircleCreation",
	"testRectangleCreation",
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

local function assertIncorrectCreation(class, className, variables, default)

	for _, badValue in ipairs({-1, "1", false, math.huge, -math.huge, NaN}) do

		local params = {}
		for i, var in ipairs(variables) do
			params[i] = default
		end

		for i, var in ipairs(variables) do
			params[i] = badValue

			success = pcall(class, unpack(params))
			if success then
				error(className .. "." .. var .. " incorrectly created with " .. tostring(badValue))
			end

			params[i] = default
		end
	end
end

function _assertIncorrectVectorAlgebra(vectorName, vector)

	for i, badValue in ipairs({{}, 1, "1", false, math.huge, -math.huge, NaN}) do
		operands = {vector, badValue}

		-- goes through (vector, badValue) then (badValue, vector)
		for first, second in pairs({2, 1}) do

			if i ~= 1 then
				success = pcall(function() return operands[first] + operands[second] end)
				if success then
					error(vectorName .. " improperly added with " .. tostring(badValue))
				end

				success = pcall(function() return operands[first] - operands[second] end)
				if success then
					error(vectorName .. " improperly subtracted with " .. tostring(badValue))
				end
			end

			if i ~= 2 then
				success = pcall(function() return operands[first] * operands[second] end)
				if success then
					error(vectorName .. " improperly multipled by " .. tostring(badValue))
				end

				success = pcall(function() return operands[first] / operands[second] end)
				if success then
					error(vectorName .. " improperly divided by " .. tostring(badValue))
				end
			end

		end
	end
end

function geometrytest.assertIncorrectVectorAlgebra()
	-- tests all possible cases of Vector2/3 algebra that should crash
	_assertIncorrectVectorAlgebra("Vector2", geometry.Vector2)
	_assertIncorrectVectorAlgebra("Vector3", geometry.Vector3)
end


function geometrytest.testVector2Add()
	-- testing accessing Vector2.__add is intentionally not covered, as it is not the proper usage

	--[[basic usage]]
	local v1 = geometry.Vector2()
	r = v1 + v1
	assert(r.x == 0, "0 + 0 didn't equal 0")
	assert(r.y == 0, "0 + 0 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v1 = geometry.Vector2(1, 5)
	local v2 = geometry.Vector2(2, 10)

	r = v1 + v1
	assert(r.x == 2, "1 + 1 didn't become 2")
	assert(r.y == 10, "5 + 5 didn't become 10")

	r = v1 + v2
	assert(r.x == 3, "1 + 2 didn't become 3")
	assert(r.y == 15, "5 + 10 didn't become 15")

	r = v2 + v1
	assert(r.x == 3, "2 + 1 didn't become 3")
	assert(r.y == 15, "10 + 5 didn't become 15")
end

function geometrytest.testVector3Add()
	-- testing accessing Vector3.__add is intentionally not covered, as it is not the proper usage

	--[[basic usage]]
	local v1 = geometry.Vector3()
	r = v1 + v1
	assert(r.x == 0, "0 + 0 didn't equal 0")
	assert(r.y == 0, "0 + 0 didn't equal 0")
	assert(r.z == 0, "0 + 0 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v1 = geometry.Vector3(1, 5, 10)
	local v2 = geometry.Vector3(2, 10, 20)

	r = v1 + v1
	assert(r.x == 2, "1 + 1 didn't become 2")
	assert(r.y == 10, "5 + 5 didn't become 10")
	assert(r.z == 20, "10 + 10 didn't become 20")

	r = v1 + v2
	assert(r.x == 3, "1 + 2 didn't become 3")
	assert(r.y == 15, "5 + 10 didn't become 15")
	assert(r.z == 30, "10 + 20 didn't become 30")

	r = v2 + v1
	assert(r.x == 3, "2 + 1 didn't become 3")
	assert(r.y == 15, "10 + 5 didn't become 15")
	assert(r.z == 30, "20 + 10 didn't become 30")
end

function geometrytest.testVector2And3Add()
	-- test vector addition that crosses vector 2 and 3

	--[[basic usage]]
	v2 = geometry.Vector2()
	v3 = geometry.Vector3()

	r = v2 + v3
	assert(r:instanceof(geometry.Vector2), "Vector2 addition didn't return Vector2")
	assert(r:instanceof(geometry.Vector3) == false, "Vector2 addition shouldn't return Vector3")
	assert(r.x == 0, "0 + 0 didn't equal 0")
	assert(r.y == 0, "0 + 0 didn't equal 0")
	assert(r.z == nil, "Vector2 shouldn't have a z value")

	r = v3 + v2
	assert(r:instanceof(geometry.Vector2), "Vector3 should be valid as Vector2")
	assert(r:instanceof(geometry.Vector3), "Vector2 addition didn't return Vector3")
	assert(r.x == 0, "0 + 0 didn't equal 0")
	assert(r.y == 0, "0 + 0 didn't equal 0")
	assert(r.z == 0, "0 + 0 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v2 = geometry.Vector2(1, 5)
	v3 = geometry.Vector3(10, 20, 30)

	r = v2 + v3
	assert(r.x == 11, "1 + 10 didn't equal 11")
	assert(r.y == 25, "5 + 20 didn't equal 25")
	assert(r.z == nil, "Vector2 shouldn't have a z value")

	r = v3 + v2
	assert(r.x == 11, "10 + 1 didn't equal 11")
	assert(r.y == 25, "20 + 5 didn't equal 25")
	assert(r.z == 30, "30 + 0 didn't equal 30")
end

function geometrytest.testVector2Subtract()
	-- testing accessing Vector2.__sub is intentionally not covered, as it is not the proper usage

	--[[basic usage]]
	local v1 = geometry.Vector2()
	v3 = v1 - v1
	assert(v3.x == 0, "0 - 0 didn't equal 0")
	assert(v3.y == 0, "0 - 0 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v1 = geometry.Vector2(1, 5)
	local v2 = geometry.Vector2(2, 10)

	v3 = v1 - v1
	assert(v3.x == 0, "1 - 1 didn't become 0")
	assert(v3.y == 0, "5 - 5 didn't become 0")

	v3 = v1 - v2
	assert(v3.x == -1, "1 - 2 didn't become -1")
	assert(v3.y == -5, "5 - 10 didn't become -5")

	v3 = v2 - v1
	assert(v3.x == 1, "2 - 1 didn't become 1")
	assert(v3.y == 5, "10 - 5 didn't become 5")
end

function geometrytest.testVector3Subtract()
	-- testing accessing Vector3.__sub is intentionally not covered, as it is not the proper usage

	--[[basic usage]]
	local v1 = geometry.Vector3()
	v3 = v1 - v1
	assert(v3.x == 0, "0 - 0 didn't equal 0")
	assert(v3.y == 0, "0 - 0 didn't equal 0")
	assert(v3.z == 0, "0 - 0 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v1 = geometry.Vector3(1, 5, 10)
	local v2 = geometry.Vector3(2, 10, 20)

	v3 = v1 - v1
	assert(v3.x == 0, "1 - 1 didn't become 0")
	assert(v3.y == 0, "5 - 5 didn't become 0")
	assert(v3.z == 0, "10 - 10 didn't become 0")

	v3 = v1 - v2
	assert(v3.x == -1, "1 - 2 didn't become -1")
	assert(v3.y == -5, "5 - 10 didn't become -5")
	assert(v3.z == -10, "10 - 20 didn't become -10")

	v3 = v2 - v1
	assert(v3.x == 1, "2 - 1 didn't become 1")
	assert(v3.y == 5, "10 - 5 didn't become 5")
	assert(v3.z == 10, "20 - 10 didn't become 10")
end

function geometrytest.testVector2And3Subtract()
	-- test vector subtraction that crosses vector 2 and 3

	--[[basic usage]]
	v2 = geometry.Vector2()
	v3 = geometry.Vector3()

	r = v2 - v3
	assert(r:instanceof(geometry.Vector2), "Vector2 addition didn't return Vector2")
	assert(r:instanceof(geometry.Vector3) == false, "Vector2 addition shouldn't return Vector3")
	assert(r.x == 0, "0 - 0 didn't equal 0")
	assert(r.y == 0, "0 - 0 didn't equal 0")
	assert(r.z == nil, "Vector2 shouldn't have a z value")

	r = v3 - v2
	assert(r:instanceof(geometry.Vector2), "Vector3 should be valid as Vector2")
	assert(r:instanceof(geometry.Vector3), "Vector2 addition didn't return Vector3")
	assert(r.x == 0, "0 - 0 didn't equal 0")
	assert(r.y == 0, "0 - 0 didn't equal 0")
	assert(r.z == 0, "0 - 0 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v2 = geometry.Vector2(1, 5)
	v3 = geometry.Vector3(10, 20, 30)

	r = v2 - v3
	assert(r.x == -9, "1 - 10 didn't equal -9")
	assert(r.y == -15, "5 - 20 didn't equal -15")
	assert(r.z == nil, "Vector2 shouldn't have a z value")

	r = v3 - v2
	assert(r.x == 9, "10 - 1 didn't equal 9")
	assert(r.y == 15, "20 - 5 didn't equal 15")
	assert(r.z == 30, "30 - 0 didn't equal 30")
end

function geometrytest.testVector2Multiply()
	-- testing accessing Vector2.__mul is intentionally not covered, as it is not the proper usage

	--[[basic usage]]
	local v = geometry.Vector2()
	r = v * 0
	assert(r.x == 0, "0 * 0 didn't equal 0")
	assert(r.y == 0, "0 * 0 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v = geometry.Vector2(1, 2)

	r = v * 2
	assert(r.x == 2, "1 * 2 didn't become 2")
	assert(r.y == 4, "2 * 2 didn't become 4")

	r = 3 * v
	assert(r.x == 3, "3 * 1 didn't become 3")
	assert(r.y == 6, "3 * 2 didn't become 6")
end

function geometrytest.testVector3Multiply()
	-- testing accessing Vector3.__mul is intentionally not covered, as it is not the proper usage

	--[[basic usage]]
	local v = geometry.Vector3()
	r = v * 0
	assert(r.x == 0, "0 * 0 didn't equal 0")
	assert(r.y == 0, "0 * 0 didn't equal 0")
	assert(r.z == 0, "0 * 0 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v = geometry.Vector3(1, 2, 3)

	r = v * 2
	assert(r.x == 2, "1 * 2 didn't become 2")
	assert(r.y == 4, "2 * 2 didn't become 4")
	assert(r.z == 6, "3 * 2 didn't become 6")

	r = 3 * v
	assert(r.x == 3, "3 * 1 didn't become 3")
	assert(r.y == 6, "3 * 2 didn't become 6")
	assert(r.z == 9, "3 * 3 didn't become 9")
end

function geometrytest.testVector2Divide()
	-- testing accessing Vector2.__div is intentionally not covered, as it is not the proper usage

	--[[basic usage]]
	local v = geometry.Vector2()
	r = v / 1
	assert(r.x == 0, "0 / 1 didn't equal 0")
	assert(r.y == 0, "0 / 1 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v = geometry.Vector2(4, 8)

	r = v / 2
	assert(r.x == 2, "4 / 2 didn't become 2")
	assert(r.y == 4, "8 / 2 didn't become 4")

	r = 4 / v
	assert(r.x == 1, "4 / 4 didn't become 1")
	assert(r.y == 2, "8 / 4 didn't become 2")
end

function geometrytest.testVector3Divide()
	-- testing accessing Vector3.__div is intentionally not covered, as it is not the proper usage

	--[[basic usage]]
	local v = geometry.Vector3()
	r = v / 1
	assert(r.x == 0, "0 / 1 didn't equal 0")
	assert(r.y == 0, "0 / 1 didn't equal 0")
	assert(r.z == 0, "0 / 1 didn't equal 0")


	--[[operator order]]
	-- uses a spread of different numbers to ensure unique results for each test
	v = geometry.Vector3(4, 8, 16)

	r = v / 2
	assert(r.x == 2, "4 / 2 didn't become 2")
	assert(r.y == 4, "8 / 2 didn't become 4")
	assert(r.z == 8, "16 / 2 didn't become 8")

	r = 4 / v
	assert(r.x == 1, "4 / 4 didn't become 1")
	assert(r.y == 2, "8 / 4 didn't become 2")
	assert(r.z == 4, "16 / 4 didn't become 4")
end

function geometrytest.testTransformCreation()

	--[[incorrect creation]]
	assertIncorrectCreation(geometry.Circle, "transform", {"position", "rotation", "size"})


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


	--[[basic creation]]
	local t1 = geometry.Transform()
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
	assert(pcall(geometry.Circle) ~= true, "circle incorrectly created with no arguments")

	assertIncorrectCreation(geometry.Circle, "circle", {"radius"})


	--[[basic creation]]
	c = geometry.Circle(0)

	assert(type(c.radius) == "number", "circle radius is not number")
	assert(c.radius == 0, "circle radius changed from given value of 0")
	assert(c.position:instanceof(geometry.Vector2), "circle position is not Vector2")
	assert(c.position.x == 0, "circle default x position is not 0")
	assert(c.position.y == 0, "circle default y position is not 0")


	--[[creation with Vector2]]
	c = geometry.Circle(1, geometry.Vector2(0, 0))

	assert(type(c.radius) == "number", "circle radius is not number")
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

end


function geometrytest.testRectangleCreation()

	--[[incorrect creation attempts]]
	assert(pcall(geometry.Rectangle) ~= true, "rectangle incorrectly created with no arguments")
	assert(pcall(geometry.Rectangle, 0) ~= true, "rectangle incorrectly created with only one argument")

	assertIncorrectCreation(geometry.Rectangle, "rectangle", {"width", "height"}, 1)


	--[[verify boundary conditions for size]]
	local r = geometry.Rectangle(0, 0)
	assert(r.width == 0, "rectangle width of 0 should be possible")
	assert(r.height == 0, "rectangle height of 0 should be possible")


	--[[basic creation]]
	r = geometry.Rectangle(1, 1)

	assert(type(r.width) == "number", "rectangle width is not number")
	assert(type(r.height) == "number", "rectangle height is not number")
	assert(r.width == 1, "rectangle width changed from given value of 1")
	assert(r.height == 1, "rectangle height changed from given value of 1")

	assert(r.position:instanceof(geometry.Vector2), "rectangle position is not Vector2")
	assert(r.position.x == 0, "rectangle default x position is not 0")
	assert(r.position.y == 0, "rectangle default y position is not 0")


	--[[creation with Vector2]]
	r = geometry.Rectangle(1, 1, geometry.Vector2(0, 0))

	assert(type(r.width) == "number", "rectangle width is not number")
	assert(type(r.height) == "number", "rectangle height is not number")
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

end

function geometrytest.testVector2Creation()

	--[[incorrect creation]]
	assertIncorrectCreation(geometry.Circle, "vector2", {"x", "y"})


	--[[purely default creation]]
	local v = geometry.Vector2()
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == nil, "Vector2 shouldn't have an existing value for z")
	assert(v:instanceof(geometry.Vector2), "Vector2 should be valid as Vector2")


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
	assert(v.z == nil, "Vector2 shouldn't have an existing value for z")


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

	assert(pcall(geometry.Vector2, 1, {}) ~= true, "incorrectly created Vector2 with table for y")

end

function geometrytest.testVector3Creation()

	--[[incorrect creation]]
	assertIncorrectCreation(geometry.Circle, "vector3", {"x", "y", "z"})


	--[[purely default creation]]
	local v = geometry.Vector3()
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")
	assert(v:instanceof(geometry.Vector3), "Vector3 should be valid as Vector3")


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

	assert(pcall(geometry.Vector3, 1, {}) ~= true, "incorrectly created Vector3 with table for y")
	assert(pcall(geometry.Vector3, 1, 1, {}) ~= true, "incorrectly created Vector3 with table for z")

end

function geometrytest.testVector2CreationWithVectors()

	--[[creation with Vector2]]
	local v = geometry.Vector2(geometry.Vector2())
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v:instanceof(geometry.Vector2), "Vector2 should be valid as Vector2")

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
	assert(v.z == nil, "Vector2 shouldn't have an existing value for z")
	assert(v:instanceof(geometry.Vector2), "Vector2 should be valid as Vector2")
	assert(v:instanceof(geometry.Vector3) == false, "Vector2 shouldn't be valid as Vector3")

	v = geometry.Vector2(geometry.Vector3(1, 1, 1))
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")
	assert(v.z == nil, "Vector2 shouldn't have an existing value for z")

	local v3 = geometry.Vector3(1, 1, 1)
	v = geometry.Vector2(v3.x, v3.y, v3.z)
	assert(v.x == 1, "Vector2 x value changed from 1")
	assert(v.y == 1, "Vector2 y value changed from 1")
	assert(v.z == nil, "Vector2 shouldn't have an existing value for z")

	v = geometry.Vector2(geometry.Vector3(), geometry.Vector3(1, 1, 1))
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == nil, "Vector2 shouldn't have an existing value for z")

end

function geometrytest.testVector3CreationWithVectors()

	--[[creation with Vector2]]
	local v = geometry.Vector3(geometry.Vector2())
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.z == 0, "Vector3 z value didn't default to 0")
	assert(v:instanceof(geometry.Vector2), "Vector3 should be valid as Vector2")
	assert(v:instanceof(geometry.Vector3), "Vector3 should be valid as Vector3")

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
	assert(v:instanceof(geometry.Vector2), "Vector3 should be valid as Vector2")
	assert(v:instanceof(geometry.Vector3), "Vector3 shouldn't be valid as Vector3")

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
	assert(r and d.shortestOverlap == cir.radius,
		"figures should be intersecting with overlap of " .. cir.radius)
end

function geometrytest.testIntersectingPolygons()

	local p1 = geometry.Polygon({-100, -50, 100, -50, 0, 50})
	local p2 = geometry.Polygon({-100, -50, 100, -50, 0, 50})
	local t1 = geometry.Transform(geometry.Vector3(0,0))
	local t2 = geometry.Transform(geometry.Vector3(100,40))

	assert(geometry.intersecting(p1, p2, t1, t2), "figures should be intersecting")

end

return geometrytest
