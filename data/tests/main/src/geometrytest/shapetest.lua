local geometry = require("lass.geometry")
local helpers = require("geometrytest.helpers")

local shapetest = {}


local function testBasicRectangleRotation(size)
    -- assumes rectangle is at origin, and has equal sides

    local r = geometry.Rectangle(size, size)
    local t = geometry.Transform()

    --[[test rotation values 0, 90, 180, 270]]
    repeat
        r = r:globalRectangle(t)

        assert(r.width == size, "rectangle width changed after a rotation of " .. t.rotation)
        assert(r.height == size, "rectangle height changed after a rotation of " .. t.rotation)
        assert(r.position.x == 0, "rectangle x position changed after a rotation of " .. t.rotation)
        assert(r.position.y == 0, "rectangle y position changed after a rotation of " .. t.rotation)

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
    assert(r2.width == width, "rectangle width changed by moving position, rotation is " .. rotation)
    assert(r2.height == height, "rectangle height changed by moving position, rotation is " .. rotation)
    assert(r2.position.x == 1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assert(r2.position.y == 0, "rectangle y position was incorrectly transformed, rotation is " .. rotation)

    t = geometry.Transform({x=-1}, rotation)
    r2 = r1:globalRectangle(t)
    assert(r2.width == width, "rectangle width changed after transforming rectangle position")
    assert(r2.height == height, "rectangle height changed after transforming rectangle position")
    assert(r2.position.x == -1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assert(r2.position.y == 0, "rectangle y position was incorrectly transformed, rotation is " .. rotation)

    t = geometry.Transform({y=1}, rotation)
    r2 = r1:globalRectangle(t)
    assert(r2.width == width, "rectangle width changed after transforming rectangle position")
    assert(r2.height == height, "rectangle height changed after transforming rectangle position")
    assert(r2.position.x == 0, "rectangle x position was incorrectly transformed, rotation is " .. rotation)
    assert(r2.position.y == 1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({y=-1}, rotation)
    r2 = r1:globalRectangle(t)
    assert(r2.width == width, "rectangle width changed after transforming rectangle position")
    assert(r2.height == height, "rectangle height changed after transforming rectangle position")
    assert(r2.position.x == 0, "rectangle x position was incorrectly transformed, rotation is " .. rotation)
    assert(r2.position.y == -1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({x=1, y=1}, rotation)
    r2 = r1:globalRectangle(t)
    assert(r2.width == width, "rectangle width changed after transforming rectangle position")
    assert(r2.height == height, "rectangle height changed after transforming rectangle position")
    assert(r2.position.x == 1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assert(r2.position.y == 1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({x=1, y=-1}, rotation)
    r2 = r1:globalRectangle(t)
    assert(r2.width == width, "rectangle width changed after transforming rectangle position")
    assert(r2.height == height, "rectangle height changed after transforming rectangle position")
    assert(r2.position.x == 1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assert(r2.position.y == -1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({x=-1, y=-1}, rotation)
    r2 = r1:globalRectangle(t)
    assert(r2.width == width, "rectangle width changed after transforming rectangle position")
    assert(r2.height == height, "rectangle height changed after transforming rectangle position")
    assert(r2.position.x == -1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assert(r2.position.y == -1, "rectangle y position wasn't transformed, rotation is " .. rotation)

    t = geometry.Transform({x=-1, y=1}, rotation)
    r2 = r1:globalRectangle(t)
    assert(r2.width == width, "rectangle width changed after transforming rectangle position")
    assert(r2.height == height, "rectangle height changed after transforming rectangle position")
    assert(r2.position.x == -1, "rectangle x position wasn't transformed, rotation is " .. rotation)
    assert(r2.position.y == 1, "rectangle y position wasn't transformed, rotation is " .. rotation)

end

function shapetest.testGlobalRectangle()

    --[[default transform]]
    local r1 = geometry.Rectangle(1, 1)
    local t = geometry.Transform()

    local r2 = r1:globalRectangle(t)
    assert(r2.width == 1, "rectangle width changed from a transform that does nothing")
    assert(r2.height == 1, "rectangle height changed from a transform that does nothing")
    assert(r2.position.x == 0, "rectangle x position changed from a transform that does nothing")
    assert(r2.position.y == 0, "rectangle y position changed from a transform that does nothing")


    --[[origin based rotation]]
    for _, size in pairs({0, 1, 2, 5000000}) do
        testBasicRectangleRotation(size)
    end


    --[[non-origin based rotation]]
    r1 = geometry.Rectangle(0, 0, geometry.Vector2(0, 1))

    t = geometry.Transform(nil, 0)
    r2 = r1:globalRectangle(t)
    assert(r2.position.x == 0, "rectangle didn't rotate position correctly")
    assert(r2.position.y == 1, "rectangle didn't rotate position correctly")

    t.rotation = 90
    r2 = r1:globalRectangle(t)
    assert(r2.position.x == 1, "rectangle didn't rotate position correctly")
    assert(r2.position.y == 0, "rectangle didn't rotate position correctly")

    t.rotation = 180
    r2 = r1:globalRectangle(t)
    assert(r2.position.x == 0, "rectangle didn't rotate position correctly")
    assert(r2.position.y == -1, "rectangle didn't rotate position correctly")

    t.rotation = 270
    r2 = r1:globalRectangle(t)
    assert(r2.position.x == -1, "rectangle didn't rotate position correctly")
    assert(r2.position.y == 0, "rectangle didn't rotate position correctly")


    --[[basic size transform]]
    r1 = geometry.Rectangle(1, 1, geometry.Vector2(1, 1))

    t = geometry.Transform(nil, nil, {x=2})
    r2 = r1:globalRectangle(t)
    assert(r2.width == 2, "rectangle width didn't get transformed by 2")
    assert(r2.height == 1, "rectangle height changed from a transform that does nothing to height")
    assert(r2.position.x == 1, "rectangle x position changed from a transform that does nothing to position x")
    assert(r2.position.y == 1, "rectangle y position changed from a transform that does nothing to position y")

    t = geometry.Transform(nil, nil, {y=2})
    r2 = r1:globalRectangle(t)
    assert(r2.width == 1, "rectangle width changed from a transform that does nothing to width")
    assert(r2.height == 2, "rectangle height didn't get transformed by 2")
    assert(r2.position.x == 1, "rectangle x position changed from a transform that does nothing to position x")
    assert(r2.position.y == 1, "rectangle y position changed from a transform that does nothing to position y")

    t = geometry.Transform(nil, nil, {x=2, y=2})
    r2 = r1:globalRectangle(t)
    assert(r2.width == 2, "rectangle width didn't get transformed by 2")
    assert(r2.height == 2, "rectangle height didn't get transformed by 2")
    assert(r2.position.x == 1, "rectangle x position changed from a transform that does nothing to position x")
    assert(r2.position.y == 1, "rectangle y position changed from a transform that does nothing to position y")


    --[[rotation of an uneven rectangle]]
    r1 = geometry.Rectangle(1, 2)

    t = geometry.Transform(nil, 0)
    r2 = r1:globalRectangle(t)
    assert(r2.width == 1, "rectangle width didn't get rotated correctly")
    assert(r2.height == 2, "rectangle height didn't get rotated correctly")
    assert(r2.position.x == 0, "rectangle x position changed from a transform that does nothing to position x")
    assert(r2.position.y == 0, "rectangle y position changed from a transform that does nothing to position y")

    t.rotation = 90
    r2 = r1:globalRectangle(t)
    assert(r2.width == 2, "rectangle width didn't get rotated correctly")
    assert(r2.height == 1, "rectangle height didn't get rotated correctly")
    assert(r2.position.x == 0, "rectangle x position changed from a transform that does nothing to position x")
    assert(r2.position.y == 0, "rectangle y position changed from a transform that does nothing to position y")

    t.rotation = 180
    r2 = r1:globalRectangle(t)
    assert(r2.width == 1, "rectangle width didn't get rotated correctly")
    assert(r2.height == 2, "rectangle height didn't get rotated correctly")
    assert(r2.position.x == 0, "rectangle x position changed from a transform that does nothing to position x")
    assert(r2.position.y == 0, "rectangle y position changed from a transform that does nothing to position y")

    t.rotation = 270
    r2 = r1:globalRectangle(t)
    assert(r2.width == 2, "rectangle width didn't get rotated correctly")
    assert(r2.height == 1, "rectangle height didn't get rotated correctly")
    assert(r2.position.x == 0, "rectangle x position changed from a transform that does nothing to position x")
    assert(r2.position.y == 0, "rectangle y position changed from a transform that does nothing to position y")


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
    assert(r2.position.x == 2, "rectangle x position wasn't transformed correctly")
    assert(r2.position.y == 3, "rectangle y position wasn't transformed correctly")

    t.rotation = 90
    r2 = r1:globalRectangle(t)
    assert(r2.position.x == 3, "rectangle x position wasn't transformed correctly")
    assert(r2.position.y == 2, "rectangle y position wasn't transformed correctly")

    t.rotation = 180
    r2 = r1:globalRectangle(t)
    assert(r2.position.x == 2, "rectangle x position wasn't transformed correctly")
    assert(r2.position.y == 1, "rectangle y position wasn't transformed correctly")

    t.rotation = 270
    r2 = r1:globalRectangle(t)
    assert(r2.position.x == 1, "rectangle x position wasn't transformed correctly")
    assert(r2.position.y == 2, "rectangle y position wasn't transformed correctly")


    --[[rotation with size transform]]
    r1 = geometry.Rectangle(1, 1)

    t = geometry.Transform(nil, 90, {x=2, y=3})
    r2 = r1:globalRectangle(t)
    assert(r2.width == 3, "rectangle width wasn't resized and/or rotated correctly")
    assert(r2.height == 2, "rectangle height wasn't resized and/or rotated correctly")

    t.rotation = 180
    r2 = r1:globalRectangle(t)
    assert(r2.width == 2, "rectangle width wasn't resized and/or rotated correctly")
    assert(r2.height == 3, "rectangle height wasn't resized and/or rotated correctly")

    t.rotation = 270
    r2 = r1:globalRectangle(t)
    assert(r2.width == 3, "rectangle width wasn't resized and/or rotated correctly")
    assert(r2.height == 2, "rectangle height wasn't resized and/or rotated correctly")


    --[[testing all three transform options together]]
    r1 = geometry.Rectangle(1, 2, geometry.Vector2(0, 1))

    t = geometry.Transform({x=1, y=-1}, 90, {x=3, y=0.5})
    r2 = r1:globalRectangle(t)
    assert(r2.width == 1, "rectangle width wasn't transformed correctly")
    assert(r2.height == 3, "rectangle height wasn't transformed correctly")
    assert(r2.position.x == 2, "rectangle x position wasn't transformed correctly")
    assert(r2.position.y == -1, "rectangle y position wasn't transformed correctly")

end

function shapetest.testCircleCreation()

    --[[incorrect creation attempts]]
    assert(pcall(geometry.Circle) ~= true, "circle incorrectly created with no arguments")

    helpers.assertIncorrectCreation(geometry.Circle, "circle", {"radius"})


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

function shapetest.testRectangleCreation()

    --[[incorrect creation attempts]]
    assert(pcall(geometry.Rectangle) ~= true, "rectangle incorrectly created with no arguments")
    assert(pcall(geometry.Rectangle, 0) ~= true, "rectangle incorrectly created with only one argument")

    helpers.assertIncorrectCreation(geometry.Rectangle, "rectangle", {"width", "height"}, 1)


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
    assert(not geometry.intersecting(c1, c2, t1, t2), "circles should not be intersecting")

    local v = geometry.Vector2(0,0)
    assert(geometry.intersecting(c1, v), "circle should contain vector")
    v.x = 0.0001
    assert(not geometry.intersecting(c1, v), "circle should not contain vector")

end

function shapetest.testIntersectingRectanglesAndVectors()

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
    assert(r and d.shortestOverlap == 0, "figures should be intersecting with overlap of 0")

    t2.position.y = 0
    r, d = geometry.intersecting(pol, cir, t1, t2)
    assert(r and d.shortestOverlap == cir.radius,
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