geometry = require "lass.geometry"

function testIntersectingCirclesAndVectors()
	local c1, c2 = geometry.Circle(3), geometry.Circle(1)
	local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(4,0))

	assert(geometry.intersecting(c1, c2), "circles at same origin aren't intersecting")
	assert(geometry.intersecting(c2, c1), "circles at same origin aren't intersecting")
	assert(geometry.intersecting(c1, c2, t1, t2), "circle edges should be touching")
	assert(geometry.intersecting(c2, c1, t2, t1), "circle edges should be touching")
	t2.position.x = 4.0001
	assert(not geometry.intersecting(c1, c2, t1, t2), "circle edges should not be touching")

	local v = geometry.Vector2(1,1)
	assert(geometry.intersecting(c1, v), "circle should contain vector")
end

function testCircleWithRadiusZero()
	local c1, c2 = geometry.Circle(0), geometry.Circle(1)
	local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(4,0))

	assert(geometry.intersecting(c1, c2), "circles at same origin aren't intersecting")
	assert(not geometry.intersecting(c1, c2, t1, t2), "circles should not be intersecting")

	local v = geometry.Vector2(0,0)
	assert(geometry.intersecting(c1, v), "circle should contain vector")
	v.x = 0.0001
	assert(not geometry.intersecting(c1, v), "circle should not contain vector")
end

function testIntersectingRectanglesAndVectors()
	local r1, r2 = geometry.Rectangle(1,2), geometry.Rectangle(1,3)
	local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(0,0))

	assert(geometry.intersecting(r1, r2), "rectangles at same origin aren't intersecting")
	assert(geometry.intersecting(r1, r2, t1, t2, true, true), "rectangles at same origin aren't intersecting")

	t2.position.y = 2
	assert(geometry.intersecting(r1, r2, t1, t2, true, true), "rectangles should be touching")
	t2.position.y = 2.00001
	assert(not geometry.intersecting(r1, r2, t1, t2, true, true), "rectangles should not be touching")

	assert(geometry.intersecting(r1, geometry.Vector2(0.5, 1)), "rectangle should contain vector")
	assert(not geometry.intersecting(r1, geometry.Vector2(-0.5, 1)), "rectangle should not contain vector")
end

function testIntersectingRectangleAndCircle()
	local rec, cir = geometry.Rectangle(1,2), geometry.Circle(3)
	local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(0,0))

	assert(geometry.intersecting(rec, cir), "figures at same origin aren't intersecting")
end

function main()

	testIntersectingCirclesAndVectors()
	testCircleWithRadiusZero()
	testIntersectingRectanglesAndVectors()
	testIntersectingRectangleAndCircle()

	print("testing complete with no assertion failures")
end

main()
