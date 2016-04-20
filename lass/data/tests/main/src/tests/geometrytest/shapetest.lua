local geometry = require("lass.geometry")
local helpers = require("tests.geometrytest.helpers")
local class = require("lass.class")
local turtlemode = require("turtlemode")

local shapetest = turtlemode.testModule()
local assertEqual = turtlemode.assertEqual
local assertNotEqual = turtlemode.assertNotEqual


local function testBasicRectangleRotation(size)
    -- assumes rectangle is at origin, and has equal sides

    local r = geometry.Rectangle(size, size)
    local t = geometry.Transform()

    --[[test rotation values 0, 90, 180, 270]]
    repeat
        r = r:globalRectangle(t)

        assertEqual(r.width, size, "rectangle width changed after a rotation of " .. t.rotation)
        assertEqual(r.height, size, "rectangle height changed after a rotation of " .. t.rotation)
        assertEqual(r.position.x, 0, "rectangle x position changed after a rotation of " .. t.rotation)
        assertEqual(r.position.y, 0, "rectangle y position changed after a rotation of " .. t.rotation)

        t.rotation = t.rotation + 90
    until(t.rotation == 0)

end

local function testRectanglePositionWithRotation(rotation)
    -- assumes rectangle is at origin, and has unequal sides

    local width = 1
    local height = 2
    local r1 = geometry.Rectangle(width, height)
    local t = geometry.Transform()

    if rotation % 90 == 0 and rotation % 180 ~= 0 then
        -- turning 90 or 270 degrees means the height/width swap
        local temp = width
        width = height
        height = temp
    end

    t = geometry.Transform({x=1}, rotation)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, width, "rectangle width changed by moving position, rotation is " .. rotation)
    assertEqual(r2.height, height, "rectangle height changed by moving position, rotation is " .. rotation)
    assertEqual(r2.position.x, 1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assertEqual(r2.position.y, 0, "rectangle y position was incorrectly transformed, rotation is " .. rotation)

    t = geometry.Transform({x=-1}, rotation)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, width, "rectangle width changed after transforming rectangle position")
    assertEqual(r2.height, height, "rectangle height changed after transforming rectangle position")
    assertEqual(r2.position.x, -1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assertEqual(r2.position.y, 0, "rectangle y position was incorrectly transformed, rotation is " .. rotation)

    t = geometry.Transform({y=1}, rotation)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, width, "rectangle width changed after transforming rectangle position")
    assertEqual(r2.height, height, "rectangle height changed after transforming rectangle position")
    assertEqual(r2.position.x, 0, "rectangle x position was incorrectly transformed, rotation is " .. rotation)
    assertEqual(r2.position.y, 1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({y=-1}, rotation)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, width, "rectangle width changed after transforming rectangle position")
    assertEqual(r2.height, height, "rectangle height changed after transforming rectangle position")
    assertEqual(r2.position.x, 0, "rectangle x position was incorrectly transformed, rotation is " .. rotation)
    assertEqual(r2.position.y, -1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({x=1, y=1}, rotation)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, width, "rectangle width changed after transforming rectangle position")
    assertEqual(r2.height, height, "rectangle height changed after transforming rectangle position")
    assertEqual(r2.position.x, 1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assertEqual(r2.position.y, 1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({x=1, y=-1}, rotation)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, width, "rectangle width changed after transforming rectangle position")
    assertEqual(r2.height, height, "rectangle height changed after transforming rectangle position")
    assertEqual(r2.position.x, 1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assertEqual(r2.position.y, -1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({x=-1, y=-1}, rotation)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, width, "rectangle width changed after transforming rectangle position")
    assertEqual(r2.height, height, "rectangle height changed after transforming rectangle position")
    assertEqual(r2.position.x, -1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assertEqual(r2.position.y, -1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({x=-1, y=1}, rotation)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, width, "rectangle width changed after transforming rectangle position")
    assertEqual(r2.height, height, "rectangle height changed after transforming rectangle position")
    assertEqual(r2.position.x, -1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assertEqual(r2.position.y, 1, "rectangle y position wasn't transformed, rotation is " .. rotation)

end

function shapetest.testGlobalRectangle()

    --[[default transform]]
    local r1 = geometry.Rectangle(1, 1)
    local t = geometry.Transform()

    local r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 1, "rectangle width changed from a transform that does nothing")
    assertEqual(r2.height, 1, "rectangle height changed from a transform that does nothing")
    assertEqual(r2.position.x, 0, "rectangle x position changed from a transform that does nothing")
    assertEqual(r2.position.y, 0, "rectangle y position changed from a transform that does nothing")


    --[[origin based rotation]]
    for _, size in pairs({0, 1, 2, 5000000}) do
        testBasicRectangleRotation(size)
    end


    --[[non-origin based rotation]]
    r1 = geometry.Rectangle(0, 0, geometry.Vector2(0, 1))

    t = geometry.Transform(nil, 0)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.position.x, 0)
    assertEqual(r2.position.y, 1)

    t.rotation = 90
    r2 = r1:globalRectangle(t)
    assertEqual(r2.position.x, 1)
    assertEqual(r2.position.y, 0)

    t.rotation = 180
    r2 = r1:globalRectangle(t)
    assertEqual(r2.position.x, 0)
    assertEqual(r2.position.y, -1)

    t.rotation = 270
    r2 = r1:globalRectangle(t)
    assertEqual(r2.position.x, -1)
    assertEqual(r2.position.y, 0)


    --[[basic size transform]]
    r1 = geometry.Rectangle(1, 1, geometry.Vector2(1, 1))

    t = geometry.Transform(nil, nil, {x=2})
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 2)
    assertEqual(r2.height, 1)
    assertEqual(r2.position.x, 1)
    assertEqual(r2.position.y, 1)

    t = geometry.Transform(nil, nil, {y=2})
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 1)
    assertEqual(r2.height, 2)
    assertEqual(r2.position.x, 1)
    assertEqual(r2.position.y, 1)

    t = geometry.Transform(nil, nil, {x=2, y=2})
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 2)
    assertEqual(r2.height, 2)
    assertEqual(r2.position.x, 1)
    assertEqual(r2.position.y, 1)


    --[[rotation of an uneven rectangle]]
    r1 = geometry.Rectangle(1, 2)

    t = geometry.Transform(nil, 0)
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 1)
    assertEqual(r2.height, 2)
    assertEqual(r2.position.x, 0)
    assertEqual(r2.position.y, 0)

    t.rotation = 90
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 2)
    assertEqual(r2.height, 1)
    assertEqual(r2.position.x, 0)
    assertEqual(r2.position.y, 0)

    t.rotation = 180
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 1)
    assertEqual(r2.height, 2)
    assertEqual(r2.position.x, 0)
    assertEqual(r2.position.y, 0)

    t.rotation = 270
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 2)
    assertEqual(r2.height, 1)
    assertEqual(r2.position.x, 0)
    assertEqual(r2.position.y, 0)


    --[[basic position transform]]
    testRectanglePositionWithRotation(0)


    --[[origin based rotation with position transform]]
    testRectanglePositionWithRotation(90)
    testRectanglePositionWithRotation(180)
    testRectanglePositionWithRotation(270)


    --[[non-origin based rotation with position transform]]
    r1 = geometry.Rectangle(1, 1, geometry.Vector2(0, 1))

    t = geometry.Transform({x=2, y=2})
    r2 = r1:globalRectangle(t)
    assertEqual(r2.position.x, 2)
    assertEqual(r2.position.y, 3)

    t.rotation = 90
    r2 = r1:globalRectangle(t)
    assertEqual(r2.position.x, 3)
    assertEqual(r2.position.y, 2)

    t.rotation = 180
    r2 = r1:globalRectangle(t)
    assertEqual(r2.position.x, 2)
    assertEqual(r2.position.y, 1)

    t.rotation = 270
    r2 = r1:globalRectangle(t)
    assertEqual(r2.position.x, 1)
    assertEqual(r2.position.y, 2)


    --[[rotation with size transform]]
    r1 = geometry.Rectangle(1, 1)

    t = geometry.Transform(nil, 90, {x=2, y=3})
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 3)
    assertEqual(r2.height, 2)

    t.rotation = 180
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 2)
    assertEqual(r2.height, 3)

    t.rotation = 270
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 3)
    assertEqual(r2.height, 2)


    --[[testing all three transform options together]]
    r1 = geometry.Rectangle(1, 2, geometry.Vector2(0, 1))

    t = geometry.Transform({x=1, y=-1}, 90, {x=3, y=0.5})
    r2 = r1:globalRectangle(t)
    assertEqual(r2.width, 1)
    assertEqual(r2.height, 3)
    assertEqual(r2.position.x, 2)
    assertEqual(r2.position.y, -1)

end

function shapetest.testCircleCreation()

    --[[incorrect creation attempts]]
    helpers.assertIncorrectValues(geometry.Circle, "circle", {"radius"}, 0, {-1, {}})


    --[[basic creation]]
    local c = geometry.Circle(0)

    assert(class.instanceof(c, geometry.Circle), "circle should be valid as a circle")

    assertEqual(type(c.radius), "number")
    assertEqual(c.radius, 0, "circle default radius is not 0")

    assert(class.instanceof(c.position, geometry.Vector2), "circle position is not Vector2")
    assertEqual(c.position.x, 0, "circle default x position is not 0")
    assertEqual(c.position.y, 0, "circle default y position is not 0")


    --[[creation with Vector2]]
    c = geometry.Circle(1, geometry.Vector2(0, 0))

    assertEqual(type(c.radius), "number")
    assertEqual(c.radius, 1)
    assert(class.instanceof(c.position, geometry.Vector2))
    assertEqual(c.position.x, 0)
    assertEqual(c.position.y, 0)

    c = geometry.Circle(1, geometry.Vector2(1, 1))
    assertEqual(c.position.x, 1)
    assertEqual(c.position.y, 1)

    c = geometry.Circle(1, geometry.Vector2(-1, -1))
    assertEqual(c.position.x, -1)
    assertEqual(c.position.y, -1)

end

function shapetest.testRectangleCreation()

    --[[incorrect creation attempts]]
    assertEqual(pcall(geometry.Rectangle), false, "rectangle incorrectly created with no arguments")
    helpers.assertIncorrectValues(geometry.Rectangle, "rectangle", {"width", "height"}, 1, {-1, {}})


    --[[verify boundary conditions for size]]
    local r = geometry.Rectangle(0, 0)
    assertEqual(r.width, 0, "rectangle width of 0 should be possible")
    assertEqual(r.height, 0, "rectangle height of 0 should be possible")


    --[[basic creation]]
    r = geometry.Rectangle(1, 1)

    assert(class.instanceof(r, geometry.Rectangle), "rectangle should be valid as a rectangle")

    assertEqual(type(r.width), "number", "rectangle width is not number")
    assertEqual(type(r.height), "number", "rectangle height is not number")
    assertEqual(r.width, 1, "rectangle width changed from given value of 1")
    assertEqual(r.height, 1, "rectangle height changed from given value of 1")

    assert(class.instanceof(r.position, geometry.Vector2), "rectangle position is not Vector2")
    assertEqual(r.position.x, 0, "rectangle default x position is not 0")
    assertEqual(r.position.y, 0, "rectangle default y position is not 0")


    --[[creation with Vector2]]
    r = geometry.Rectangle(1, 1, geometry.Vector2(0, 0))

    assertEqual(type(r.width), "number")
    assertEqual(type(r.height), "number")
    assertEqual(r.width, 1)
    assertEqual(r.height, 1)

    assert(class.instanceof(r.position, geometry.Vector2))
    assertEqual(r.position.x, 0)
    assertEqual(r.position.y, 0)

    r = geometry.Rectangle(1, 1, geometry.Vector2(1, 1))
    assertEqual(r.position.x, 1)
    assertEqual(r.position.y, 1)

    r = geometry.Rectangle(1, 1, geometry.Vector2(-1, -1))
    assertEqual(r.position.x, -1)
    assertEqual(r.position.y, -1)

end

function shapetest.testIntersectingCirclesAndVectors()

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

function shapetest.testCircleWithRadiusZero()

    local c1, c2 = geometry.Circle(0), geometry.Circle(1)
    local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(4,0))

    assert(geometry.intersecting(c1, c2), "circles at same position aren't intersecting")
    assertEqual(geometry.intersecting(c1, c2, t1, t2), false, "circles should not be intersecting")

    local v = geometry.Vector2(0,0)
    assert(geometry.intersecting(c1, v), "circle should contain vector")
    v.x = 0.0001
    assertEqual(geometry.intersecting(c1, v), false, "circle should not contain vector")

end

function shapetest.testIntersectingRectanglesAndVectors()

    local r1, r2 = geometry.Rectangle(1,2), geometry.Rectangle(1,3)
    local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(0,0))
    local colliding, data

    assert(geometry.intersecting(r1, r2), "rectangles at same position aren't intersecting")
    assert(geometry.intersecting(r1, r2, t1, t2, true, true), "rectangles at same position aren't intersecting")


    t2.position.y = 2.5
    colliding, data = geometry.intersecting(r1, r2, t1, t2, true, true)
    assertEqual(colliding and data.shortestOverlap, 0, "rectangles should be touching with overlap of 0")

    t2.position.y = 2.50001
    colliding, data = geometry.intersecting(r1, r2, t1, t2, true, true)
    assertEqual(colliding, false, "rectangles should not be touching")

    t2.position.y = 1.5
    colliding, data = geometry.intersecting(r1, r2, t1, t2, true, true)
    assertEqual(colliding and data.shortestOverlap, 1, "rectangles should be touching with overlap of 1")

    assert(geometry.intersecting(r1, geometry.Vector2(0.5, -1)), "rectangle should contain vector")
    assertEqual(geometry.intersecting(r1, geometry.Vector2(0.5, 1.01)), false,
        "rectangle should not contain vector")

end

function shapetest.testIntersectingRectangleAndCircle()

    local rec, cir = geometry.Rectangle(1,2), geometry.Circle(3)
    local t1, t2 = geometry.Transform(geometry.Vector3(0,0)), geometry.Transform(geometry.Vector3(0,0))

    assert(geometry.intersecting(rec, cir), "figures at same origin aren't intersecting")

    t2.position.x = 3.5
    assert(geometry.intersecting(rec, cir, t1, t2), "figures should be touching")
    t2.position.x = 4.001
    assert(not geometry.intersecting(rec, cir, t1, t2), "figures should not be touching")

end

function shapetest.testIntersectingPolygonsAndVectors()

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
    assertEqual(geometry.intersecting(p1, p2, t1, t2), false, "polygons should not be touching")

    assert(geometry.intersecting(p1, geometry.Vector2(0,0)), "polygon should contain vector")
    assert(geometry.intersecting(geometry.Vector2(0,0), p1), "polygon should contain vector")
    assert(p1:globalPolygon(t1):contains(geometry.Vector2(0,0)), "polygon should contain vector")

    assert(geometry.intersecting(p1, geometry.Vector2(100,-50)), "polygon should contain vector")
    assert(geometry.intersecting(geometry.Vector2(100,-50), p1), "polygon should contain vector")
    assert(p1:globalPolygon(t1):contains(geometry.Vector2(100,-50)), "polygon should contain vector")

    assertEqual(geometry.intersecting(p1, geometry.Vector2(100,-50.0001)), false,
        "polygon should not contain vector")
    assertEqual(geometry.intersecting(geometry.Vector2(100,-50.0001), p1), false,
        "polygon should not contain vector")
    assertEqual(p1:globalPolygon(t1):contains(geometry.Vector2(100,-50.0001)), false,
        "polygon should not contain vector")
end

function shapetest.testIntersectingPolygonAndCircle()

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
    assertEqual(r and d.shortestOverlap, 0, "figures should be intersecting with overlap of 0")

    t2.position.y = 0
    r, d = geometry.intersecting(pol, cir, t1, t2)
    assertEqual(r and d.shortestOverlap, cir.radius,
        "figures should be intersecting with overlap of " .. cir.radius)
end

function shapetest.testIntersectingPolygons()

    local p1 = geometry.Polygon({-100, -50, 100, -50, 0, 50})
    local p2 = geometry.Polygon({-100, -50, 100, -50, 0, 50})
    local t1 = geometry.Transform(geometry.Vector3(0,0))
    local t2 = geometry.Transform(geometry.Vector3(100,40))

    assert(geometry.intersecting(p1, p2, t1, t2), "figures should be intersecting")
end

return shapetest