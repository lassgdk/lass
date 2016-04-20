local geometry = require("lass.geometry")
local helpers = require("tests.geometrytest.helpers")
local class = require("lass.class")
local turtlemode = require("turtlemode")

local vectortest = turtlemode.testModule()
local assertEqual = turtlemode.assertEqual
local assertNotEqual = turtlemode.assertNotEqual


function vectortest.testVector2Creation()

    --[[incorrect creation]]
    helpers.assertIncorrectValues(geometry.Vector2, "vector2", {"x", "y"}, 0)


    --[[purely default creation]]
    local v = geometry.Vector2()
    assertEqual(v.x, 0, "Vector2 x value didn't default to 0")
    assertEqual(v.y, 0, "Vector2 y value didn't default to 0")
    assertEqual(v.z, nil, "Vector2 shouldn't have an existing value for z")
    assert(class.instanceof(v, geometry.Vector2), "Vector2 should be valid as Vector2")
    assertEqual(class.instanceof(v, geometry.Vector3), false, "Vector2 should not be valid as Vector3")


    --[[creation with just numbers]]
    v = geometry.Vector2(1)
    assertEqual(v.x, 1)
    assertEqual(v.y, 0)

    v = geometry.Vector2(1, 1)
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)

    v = geometry.Vector2(1, 1, 1)
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, nil)


    --[[creation with just tables]]
    v = geometry.Vector2({})
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)

    -- values given here should be ignored
    v = geometry.Vector2({1, 1})
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)

    v = geometry.Vector2({x = 1, y = 1})
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    
    -- second table should be ignored
    v = geometry.Vector2({}, {x = 1, y = 1})
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)


    --[[creation with tables and numbers]]
    -- second value should be ignored
    v = geometry.Vector2({}, 1)
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)

end

function vectortest.testVector3Creation()

    --[[incorrect creation]]
    helpers.assertIncorrectValues(geometry.Vector3, "vector3", {"x", "y", "z"}, 0)


    --[[purely default creation]]
    local v = geometry.Vector3()
    assertEqual(v.x, 0, "Vector3 x value didn't default to 0")
    assertEqual(v.y, 0, "Vector3 y value didn't default to 0")
    assertEqual(v.z, 0, "Vector3 z value didn't default to 0")
    assert(class.instanceof(v, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3), "Vector3 should be valid as Vector3")


    --[[creation with just numbers]]
    v = geometry.Vector3(1)
    assertEqual(v.x, 1)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)

    v = geometry.Vector3(1, 1)
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, 0)

    v = geometry.Vector3(1, 1, 1)
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, 1)


    --[[creation with just tables]]
    v = geometry.Vector3({})
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)

    -- values here should be ignored
    v = geometry.Vector3({1, 1, 1})
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)

    v = geometry.Vector3({x = 1, y = 1, z = 1})
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, 1)

    -- second table should be ignored
    v = geometry.Vector3({}, {x = 1, y = 1, z = 1})
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)


    --[[creation with tables and numbers]]
    -- second and third values should be ignored
    v = geometry.Vector3({}, 1, 1)
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)

end

function vectortest.testVector2CreationWithVectors()

    --[[creation with Vector2]]
    local v = geometry.Vector2(geometry.Vector2())
    assertEqual(v.x, 0, "Vector2 x value didn't default to 0")
    assertEqual(v.y, 0, "Vector2 y value didn't default to 0")
    assert(class.instanceof(v, geometry.Vector2), "Vector2 should be valid as Vector2")
    assertEqual(class.instanceof(v, geometry.Vector3), false, "Vector2 should not be valid as Vector3")

    v = geometry.Vector2(geometry.Vector2(1, 1))
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)

    local v2 = geometry.Vector2(1, 1)
    v = geometry.Vector2(v2.x, v2.y)
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)

    v = geometry.Vector2(geometry.Vector2(), geometry.Vector2(1, 1))
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)


    --[[creation with Vector3]]
    v = geometry.Vector2(geometry.Vector3())
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, nil)
    assert(class.instanceof(v, geometry.Vector2), "Vector2 should be valid as Vector2")
    assertEqual(class.instanceof(v, geometry.Vector3), false, "Vector2 shouldn't be valid as Vector3")

    v = geometry.Vector2(geometry.Vector3(1, 1, 1))
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, nil)

    local v3 = geometry.Vector3(1, 1, 1)
    v = geometry.Vector2(v3.x, v3.y, v3.z)
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, nil)

    v = geometry.Vector2(geometry.Vector3(), geometry.Vector3(1, 1, 1))
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, nil)

end

function vectortest.testVector3CreationWithVectors()

    --[[creation with Vector2]]
    local v = geometry.Vector3(geometry.Vector2())
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)
    assert(class.instanceof(v, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3), "Vector3 should be valid as Vector3")

    v = geometry.Vector3(geometry.Vector2(1, 1))
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, 0)

    local v2 = geometry.Vector2(1, 1)
    v = geometry.Vector3(v2.x, v2.y)
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, 0)

    v = geometry.Vector3(geometry.Vector2(), geometry.Vector2(1, 1))
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)


    --[[creation with Vector3]]
    v = geometry.Vector3(geometry.Vector3())
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)
    assert(class.instanceof(v, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3), "Vector3 should be valid as Vector3")

    v = geometry.Vector3(geometry.Vector3(1, 1, 1))
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, 1)

    local v3 = geometry.Vector3(1, 1, 1)
    v = geometry.Vector3(v3.x, v3.y, v3.z)
    assertEqual(v.x, 1)
    assertEqual(v.y, 1)
    assertEqual(v.z, 1)

    v = geometry.Vector3(geometry.Vector3(), geometry.Vector3(1, 1, 1))
    assertEqual(v.x, 0)
    assertEqual(v.y, 0)
    assertEqual(v.z, 0)

end

function vectortest.testVectorComparison()


    --[[vector2 to vector2]]
    local v1 = geometry.Vector2()
    local v2 = geometry.Vector2()
    assertEqual(v1, v2)

    v1.x = 1
    assertNotEqual(v1, v2)
    v2.x = 1
    assertEqual(v1, v2)

    v1.y = 1
    assertNotEqual(v1, v2)
    v2.y = 1
    assertEqual(v1, v2)


    --[[vector3 to vector3]]
    local v3 = geometry.Vector3()
    local v4 = geometry.Vector3()
    assertEqual(v3, v4)

    v3.x = 1
    assertNotEqual(v3, v4)
    v4.x = 1
    assertEqual(v3, v4)

    v3.y = 1
    assertNotEqual(v3, v4)
    v4.y = 1
    assertEqual(v3, v4)

    v3.z = 1
    assertNotEqual(v3, v4)
    v4.z = 1
    assertEqual(v3, v4)


    --[[cross-vector comparison]]
    v2 = geometry.Vector2()
    v3 = geometry.Vector3()
    assertNotEqual(v2, v3)

    v2.z = 0
    assertNotEqual(v2, v3)

end

function vectortest.testUnaryMinus()

    --[[testing with Vector2]]
    local v2 = geometry.Vector2()
    local r = -v2
    assertEqual(r, v2)

    v2 = geometry.Vector2(1, 1)
    r = -v2
    assertEqual(r, geometry.Vector2(-1, -1))

    v2 = geometry.Vector2(-1, -1)
    r = -v2
    assertEqual(r, geometry.Vector2(1, 1))


    --[[testing with Vector3]]
    local v3 = geometry.Vector3()
    local r = -v3
    assertEqual(r, v3)

    v3 = geometry.Vector3(1, 1, 1)
    r = -v3
    assertEqual(r, geometry.Vector3(-1, -1, -1))

    v3 = geometry.Vector3(-1, -1, -1)
    r = -v3
    assertEqual(r, geometry.Vector3(1, 1, 1))

end

function vectortest.testVector2MagnitudeAndSqrMagnitude()

    --[[0,0 to 0,0]]
    local origin = geometry.Vector2()
    local v2 = geometry.Vector2()
    assertEqual(v2:magnitude(origin), 0)
    assertEqual(v2:sqrMagnitude(origin), 0)


    --[[0,0 to all negations of 5,5]]
    origin = geometry.Vector2()
    v2 = geometry.Vector2(5, 5)
    assertEqual(v2:magnitude(origin), math.sqrt(50))
    assertEqual(v2:sqrMagnitude(origin), 50)

    v2 = geometry.Vector2(-5, 5)
    assertEqual(v2:magnitude(origin), math.sqrt(50))
    assertEqual(v2:sqrMagnitude(origin), 50)

    v2 = geometry.Vector2(5, -5)
    assertEqual(v2:magnitude(origin), math.sqrt(50))
    assertEqual(v2:sqrMagnitude(origin), 50)

    v2 = geometry.Vector2(-5, -5)
    assertEqual(v2:magnitude(origin), math.sqrt(50))
    assertEqual(v2:sqrMagnitude(origin), 50)


    --[[1,1 to all negations of 2,2]]
    origin = geometry.Vector2(1, 1)
    v2 = geometry.Vector2(2, 2)
    assertEqual(v2:magnitude(origin), math.sqrt(2))
    assertEqual(v2:sqrMagnitude(origin), 2)

    v2 = geometry.Vector2(-2, 2)
    assertEqual(v2:magnitude(origin), math.sqrt(10))
    assertEqual(v2:sqrMagnitude(origin), 10)

    v2 = geometry.Vector2(2, -2)
    assertEqual(v2:magnitude(origin), math.sqrt(10))
    assertEqual(v2:sqrMagnitude(origin), 10)

    v2 = geometry.Vector2(-2, -2)
    assertEqual(v2:magnitude(origin), math.sqrt(18))
    assertEqual(v2:sqrMagnitude(origin), 18)

end

function vectortest.testVector3MagnitudeAndSqrMagnitude()

    --[[0,0,0 to 0,0,0]]
    local origin = geometry.Vector3()
    local v3 = geometry.Vector3()
    assertEqual(v3:magnitude(origin), 0)
    assertEqual(v3:sqrMagnitude(origin), 0)


    --[[0,0,0 to all negations of 5,5,5]]
    origin = geometry.Vector3()
    v2 = geometry.Vector3(5, 5, 5)
    assertEqual(v2:magnitude(origin), math.sqrt(75))
    assertEqual(v2:sqrMagnitude(origin), 75)

    v2 = geometry.Vector3(-5, 5, -5)
    assertEqual(v2:magnitude(origin), math.sqrt(75))
    assertEqual(v2:sqrMagnitude(origin), 75)

    v2 = geometry.Vector3(5, -5, 5)
    assertEqual(v2:magnitude(origin), math.sqrt(75))
    assertEqual(v2:sqrMagnitude(origin), 75)

    v2 = geometry.Vector3(-5, -5, -5)
    assertEqual(v2:magnitude(origin), math.sqrt(75))
    assertEqual(v2:sqrMagnitude(origin), 75)


    --[[1,1,1 to all negations of 2,2,2]]
    origin = geometry.Vector3(1, 1,1)
    v2 = geometry.Vector3(2, 2, 2)
    assertEqual(v2:magnitude(origin), math.sqrt(3))
    assertEqual(v2:sqrMagnitude(origin), 3)

    v2 = geometry.Vector3(-2, 2, -2)
    assertEqual(v2:magnitude(origin), math.sqrt(19))
    assertEqual(v2:sqrMagnitude(origin), 19)

    v2 = geometry.Vector3(2, -2, 2)
    assertEqual(v2:magnitude(origin), math.sqrt(11))
    assertEqual(v2:sqrMagnitude(origin), 11)

    v2 = geometry.Vector3(-2, -2, -2)
    assertEqual(v2:magnitude(origin), math.sqrt(27))
    assertEqual(v2:sqrMagnitude(origin), 27)

end

function vectortest.testVectorToString()

    --[[testing Vector2]]
    local v2 = geometry.Vector2()
    assertEqual(tostring(v2), "{x=0.00, y=0.00}")

    v2 = geometry.Vector2(1, 2)
    assertEqual(tostring(v2), "{x=1.00, y=2.00}")

    v2 = geometry.Vector2(1.1, 2.2)
    assertEqual(tostring(v2), "{x=1.10, y=2.20}")

    v2 = geometry.Vector2(3.33, 4.44)
    assertEqual(tostring(v2), "{x=3.33, y=4.44}")

    -- account for rounding
    v2 = geometry.Vector2(5.555, 6.666)
    assertEqual(tostring(v2), "{x=5.55, y=6.67}")

    -- negative, and negative rounding
    v2 = geometry.Vector2(-5.001, -8.009)
    assertEqual(tostring(v2), "{x=-5.00, y=-8.01}")


    --[[testing Vector3]]
    local v3 = geometry.Vector3()
    assertEqual(tostring(v3), "{x=0.00, y=0.00, z=0.00}")

    v3 = geometry.Vector3(1, 2, 3)
    assertEqual(tostring(v3), "{x=1.00, y=2.00, z=3.00}")

    v3 = geometry.Vector3(1.1, 2.2, 3.3)
    assertEqual(tostring(v3), "{x=1.10, y=2.20, z=3.30}")

    v3 = geometry.Vector3(3.33, 4.44, 5.55)
    assertEqual(tostring(v3), "{x=3.33, y=4.44, z=5.55}")

    -- account for rounding
    v3 = geometry.Vector3(5.555, 6.666, 7.777)
    assertEqual(tostring(v3), "{x=5.55, y=6.67, z=7.78}")

    -- negative, and negative rounding
    v3 = geometry.Vector3(-5.001, -8.009, -12.005)
    assertEqual(tostring(v3), "{x=-5.00, y=-8.01, z=-12.01}")

end

function vectortest.testVectorDot()

    --[[testing Vector2]]
    local v1 = geometry.Vector2()
    local v2 = geometry.Vector2()
    assertEqual(v1:dot(v2), 0)

    v1 = geometry.Vector2(1, 1)
    v2 = geometry.Vector2(0, 0)
    assertEqual(v1:dot(v2), 0)

    v1 = geometry.Vector2(2, 2)
    v2 = geometry.Vector2(3, 5)
    assertEqual(v1:dot(v2), 16)

    v1 = geometry.Vector2(2, 2)
    v2 = geometry.Vector2(1, -1)
    assertEqual(v1:dot(v2), 0)

    v1 = geometry.Vector2(2, 2)
    v2 = geometry.Vector2(-3, -5)
    assertEqual(v1:dot(v2), -16)


    --[[testing Vector3]]
    v1 = geometry.Vector3()
    v2 = geometry.Vector3()
    assertEqual(v1:dot(v2), 0)

    v1 = geometry.Vector3(1, 1, 1)
    v2 = geometry.Vector3(0, 0, 0)
    assertEqual(v1:dot(v2), 0)

    v1 = geometry.Vector3(2, 2, 2)
    v2 = geometry.Vector3(3, 5, 7)
    assertEqual(v1:dot(v2), 30)

    v1 = geometry.Vector3(2, 2, 2)
    v2 = geometry.Vector3(1, -1, 0)
    assertEqual(v1:dot(v2), 0)

    v1 = geometry.Vector3(2, 2, 2)
    v2 = geometry.Vector3(-3, -5, -7)
    assertEqual(v1:dot(v2), -30)

end

function vectortest.testVector2Project()

    --[[incorrect usage]]
    local v2 = geometry.Vector2()
    local dir = geometry.Vector2()

    assertEqual(pcall(function() v2:project(dir) end), false, "an invalid direction vector was accepted")


    --[[basic usage]]
    v2 = geometry.Vector2()
    local horiz = geometry.Vector2(1, 0)
    local vert = geometry.Vector2(0, 1)
    local upward = geometry.Vector2(1, 1)
    local downward = geometry.Vector2(-1, 1)

    local r = v2:project(horiz)
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)

    r = v2:project(vert)
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)

    r = v2:project(upward)
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)

    r = v2:project(downward)
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)


    --[[simple / first quadrant projection]]
    -- only this section should repeat the x/y == 0 for horiz/vert projections,
    -- since after that we know a non-zero starting point will always be rendered correctly
    v2 = geometry.Vector2(1, 5)

    r = v2:project(horiz)
    assertEqual(r.x, 1)
    assertEqual(r.y, 0)

    r = v2:project(vert)
    assertEqual(r.x, 0)
    assertEqual(r.y, 5)

    r = v2:project(upward)
    assertEqual(r.x, 3)
    assertEqual(r.y, 3)

    r = v2:project(downward)
    assertEqual(r.x, -2)
    assertEqual(r.y, 2)


    --[[second quadrant projection]]
    v2 = geometry.Vector2(-1, 5)

    r = v2:project(horiz)
    assertEqual(r.x, -1)

    r = v2:project(vert)
    assertEqual(r.y, 5)

    r = v2:project(upward)
    assertEqual(r.x, 2)
    assertEqual(r.y, 2)

    r = v2:project(downward)
    assertEqual(r.x, -3)
    assertEqual(r.y, 3)


    --[[third quadrant projection]]
    v2 = geometry.Vector2(-1, -5)

    r = v2:project(horiz)
    assertEqual(r.x, -1)

    r = v2:project(vert)
    assertEqual(r.y, -5)

    r = v2:project(upward)
    assertEqual(r.x, -3)
    assertEqual(r.y, -3)

    r = v2:project(downward)
    assertEqual(r.x, 2)
    assertEqual(r.y, -2)


    --[[fourth quadrant projection]]
    v2 = geometry.Vector2(1, -5)

    r = v2:project(horiz)
    assertEqual(r.x, 1)

    r = v2:project(vert)
    assertEqual(r.y, -5)

    r = v2:project(upward)
    assertEqual(r.x, -2)
    assertEqual(r.y, -2)

    r = v2:project(downward)
    assertEqual(r.x, 3)
    assertEqual(r.y, -3)


    --[[equivelance of >1 magnitude direction vectors]]
    v2 = geometry.Vector2(1, 5)
    horiz = geometry.Vector2(10, 0)
    vert = geometry.Vector2(0, 100)
    upward = geometry.Vector2(20, 20)
    downward = geometry.Vector2(-25, 25)
    
    r = v2:project(horiz)
    assertEqual(r.x, 1)
    assertEqual(r.y, 0)

    r = v2:project(vert)
    assertEqual(r.x, 0)
    assertEqual(r.y, 5)

    r = v2:project(upward)
    assertEqual(r.x, 3)
    assertEqual(r.y, 3)

    r = v2:project(downward)
    assertEqual(r.x, -2)
    assertEqual(r.y, 2)


    --[[equivelance of negated direction vectors]]
    v2 = geometry.Vector2(1, 5)
    horiz = geometry.Vector2(-1, 0)
    vert = geometry.Vector2(0, -1)
    upward = geometry.Vector2(-1, -1)
    downward = geometry.Vector2(1, -1)

    r = v2:project(horiz)
    assertEqual(r.x, 1)
    assertEqual(r.y, 0)

    r = v2:project(vert)
    assertEqual(r.x, 0)
    assertEqual(r.y, 5)

    r = v2:project(upward)
    assertEqual(r.x, 3)
    assertEqual(r.y, 3)

    r = v2:project(downward)
    assertEqual(r.x, -2)
    assertEqual(r.y, 2)


end

function vectortest.testVector2Angle()

    local degrees_conv = 180/math.pi

    --[[basic usage]]
    local v2 = geometry.Vector2()
    assertEqual(v2:angle(true), math.huge)
    assertEqual(v2:angle(), math.huge)


    --[[simple 8 directions]]
    v2 = geometry.Vector2(1, 0)
    assertEqual(v2:angle(true), 0)
    assertEqual(v2:angle(), 0)

    v2 = geometry.Vector2(1, 1)
    assertEqual(v2:angle(true), math.rad(45))
    assertEqual(v2:angle(), 45)

    v2 = geometry.Vector2(0, 1)
    assertEqual(v2:angle(true), math.pi * 0.5)
    assertEqual(v2:angle(), math.deg(math.pi * 0.5))

    v2 = geometry.Vector2(-1, 1)
    assertEqual(v2:angle(true), math.rad(135))
    assertEqual(v2:angle(), 135)

    v2 = geometry.Vector2(-1, 0)
    assertEqual(v2:angle(true), math.rad(180))
    assertEqual(v2:angle(), 180)

    v2 = geometry.Vector2(-1, -1)
    assertEqual(v2:angle(true), math.rad(225))
    assertEqual(v2:angle(), 225)

    v2 = geometry.Vector2(0, -1)
    assertEqual(v2:angle(true), math.pi * 1.5)
    assertEqual(v2:angle(), math.deg(math.pi * 1.5))

    v2 = geometry.Vector2(1, -1)
    assertEqual(v2:angle(true), math.rad(315))
    assertEqual(v2:angle(), 315)

end

function vectortest.testVector3Angle()

    --[[basic usage]]
    local v3 = geometry.Vector3()
    assertEqual(v3:angle(true), math.huge)
    assertEqual(v3:angle(), math.huge)


    --[[simple 8 directions]]
    v3 = geometry.Vector3(1, 0, 5)
    assertEqual(v3:angle(true), 0)
    assertEqual(v3:angle(), 0)

    v3 = geometry.Vector3(1, 1, 50)
    assertEqual(v3:angle(true), math.rad(45))
    assertEqual(v3:angle(), 45)

    v3 = geometry.Vector3(0, 1, 55)
    assertEqual(v3:angle(true), math.pi * 0.5)
    assertEqual(v3:angle(), math.deg(math.pi * 0.5))

    v3 = geometry.Vector3(-1, 1, 500)
    assertEqual(v3:angle(true), math.rad(135))
    assertEqual(v3:angle(), 135)

    v3 = geometry.Vector3(-1, 0, 505)
    assertEqual(v3:angle(true), math.rad(180))
    assertEqual(v3:angle(), 180)

    v3 = geometry.Vector3(-1, -1, 555)
    assertEqual(v3:angle(true), math.rad(225))
    assertEqual(v3:angle(), 225)

    v3 = geometry.Vector3(0, -1, 5000)
    assertEqual(v3:angle(true), math.pi * 1.5)
    assertEqual(v3:angle(), math.deg(math.pi * 1.5))

    v3 = geometry.Vector3(1, -1, 5005)
    assertEqual(v3:angle(true), math.rad(315))
    assertEqual(v3:angle(), 315)

end

return vectortest
