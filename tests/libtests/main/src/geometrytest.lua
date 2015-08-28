geometry = require "lass.geometry"

local geometrytest = {}

geometrytest.tests={
	"testRectangleCreation",
	"testVector2Creation",
	"testVector3Creation",
	"testIntersectingCirclesAndVectors",
	"testCircleWithRadiusZero",
	"testIntersectingRectanglesAndVectors",
	"testIntersectingRectangleAndCircle",
	"testIntersectingPolygonsAndVectors",
	"testIntersectingPolygonAndCircle",
	"testIntersectingPolygons",
}

function geometrytest.testRectangleCreation()

	assert(pcall(geometry.Rectangle) ~= true, "rectangle incorrectly created with no arguments")
	assert(pcall(geometry.Rectangle, 0) ~= true, "rectangle incorrectly created with only one argument")

	assert(pcall(geometry.Rectangle, 0, 1) ~= true, "rectangle incorrectly created with 0 width")
	assert(pcall(geometry.Rectangle, -1, 1) ~= true, "rectangle incorrectly created with -1 width")

	assert(pcall(geometry.Rectangle, 1, 0) ~= true, "rectangle incorrectly created with 0 height")
	assert(pcall(geometry.Rectangle, 1, -1) ~= true, "rectangle incorrectly created with -1 height")


	local r = geometry.Rectangle(1, 1)

	assert(type(r.width) == "number", "rectangle width is not a number")
	assert(type(r.height) == "number", "rectangle height is not a number")
	assert(r.width == 1, "rectangle width changed from given value of 1")
	assert(r.height == 1, "rectangle height changed from given value of 1")

	assert(r.position:instanceof(geometry.Vector2), "rectangle position is not Vector2")
	assert(r.position.x == 0, "rectangle default x position is not 0")
	assert(r.position.y == 0, "rectangle default y position is not 0")


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


	r = geometry.Rectangle(math.huge, math.huge, geometry.Vector2(math.huge, math.huge))
	assert(r.width == math.huge, "rectangle width changed from given value of math.huge")
	assert(r.height == math.huge, "rectangle height changed from given value of math.huge")
	assert(r.position.x == math.huge, "rectangle x position changed from given value of math.huge")
	assert(r.position.y == math.huge, "rectangle y position changed from given value of math.huge")


	local v = geometry.Vector2(geometry.Vector3(1, 1))
	r = geometry.Rectangle(1, 1, v)

	assert(r.position:instanceof(geometry.Vector2), "rectangle position shouldn't be Vector3")
	assert(r.position:instanceof(geometry.Vector3) == false, "rectangle position shouldn't be Vector3")
	assert(r.position.x == 1, "rectangle x position changed from given value of 1")
	assert(r.position.y == 1, "rectangle y position changed from given value of 1")
	assert(r.position.z == nil, "rectangle z position shouldn't exist")

	v = geometry.Vector2(geometry.Vector3(1, 1, 1))
	r = geometry.Rectangle(1, 1, v)

	assert(r.position:instanceof(geometry.Vector2), "rectangle position shouldn't be Vector3")
	assert(r.position:instanceof(geometry.Vector3) == false, "rectangle position shouldn't be Vector3")
	assert(r.position.x == 1, "rectangle x position changed from given value of 1")
	assert(r.position.y == 1, "rectangle y position changed from given value of 1")
	assert(r.position.z == nil, "rectangle z position shouldn't exist")


end

function geometrytest.testVector2Creation()

	local v = geometry.Vector2()
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == nil, "Vector2 shouldn't have a z value")

	v = geometry.Vector2({})
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")

	v = geometry.Vector2(geometry.Vector3())

	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == nil, "Vector2 shouldn't have a z value")
	assert(v:instanceof(geometry.Vector2), "Vector2 should be valid as a Vector2")
	assert(v:instanceof(geometry.Vector3) == false, "Vector2 shouldn't be valid as a Vector3")

end

function geometrytest.testVector3Creation()

	local v = geometry.Vector3()
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == 0, "Vector2 z value didn't default to 0")

	v = geometry.Vector3({})
	assert(v.x == 0, "Vector2 x value didn't default to 0")
	assert(v.y == 0, "Vector2 y value didn't default to 0")
	assert(v.z == 0, "Vector2 z value didn't default to 0")

	v = geometry.Vector3(geometry.Vector2())
	assert(v.x == 0, "Vector3 x value didn't default to 0")
	assert(v.y == 0, "Vector3 y value didn't default to 0")
	assert(v.y == 0, "Vector3 z value didn't default to 0")
	assert(v:instanceof(geometry.Vector2), "Vector3 should be valid as a Vector2")
	assert(v:instanceof(geometry.Vector3), "Vector3 should be valid as a Vector3")

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
