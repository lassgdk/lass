local geometry = require("lass.geometry")
local helpers = require("geometrytest.helpers")
local class = require("lass.class")

local vectortest = {}


function vectortest.testVector2Creation()

    --[[incorrect creation]]
    helpers.assertIncorrectValues(geometry.Vector2, "vector2", {"x", "y"}, 0, false, false)


    --[[purely default creation]]
    local v = geometry.Vector2()
    assert(v.x == 0, "Vector2 x value didn't default to 0")
    assert(v.y == 0, "Vector2 y value didn't default to 0")
    assert(v.z == nil, "Vector2 shouldn't have an existing value for z")
    assert(class.instanceof(v, geometry.Vector2), "Vector2 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3) ~= true, "Vector2 should not be valid as Vector3")


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

function vectortest.testVector3Creation()

    --[[incorrect creation]]
    helpers.assertIncorrectValues(geometry.Vector3, "vector3", {"x", "y", "z"}, 0, false, false)


    --[[purely default creation]]
    local v = geometry.Vector3()
    assert(v.x == 0, "Vector3 x value didn't default to 0")
    assert(v.y == 0, "Vector3 y value didn't default to 0")
    assert(v.z == 0, "Vector3 z value didn't default to 0")
    assert(class.instanceof(v, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3), "Vector3 should be valid as Vector3")


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

function vectortest.testVector2CreationWithVectors()

    --[[creation with Vector2]]
    local v = geometry.Vector2(geometry.Vector2())
    assert(v.x == 0, "Vector2 x value didn't default to 0")
    assert(v.y == 0, "Vector2 y value didn't default to 0")
    assert(class.instanceof(v, geometry.Vector2), "Vector2 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3) ~= true, "Vector2 should not be valid as Vector3")

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
    assert(class.instanceof(v, geometry.Vector2), "Vector2 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3) == false, "Vector2 shouldn't be valid as Vector3")

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

function vectortest.testVector3CreationWithVectors()

    --[[creation with Vector2]]
    local v = geometry.Vector3(geometry.Vector2())
    assert(v.x == 0, "Vector3 x value didn't default to 0")
    assert(v.y == 0, "Vector3 y value didn't default to 0")
    assert(v.z == 0, "Vector3 z value didn't default to 0")
    assert(class.instanceof(v, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3), "Vector3 should be valid as Vector3")

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
    assert(class.instanceof(v, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(v, geometry.Vector3), "Vector3 should be valid as Vector3")

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

function vectortest.testVectorComparison()


    --[[vector2 to vector2]]
    local v1 = geometry.Vector2()
    local v2 = geometry.Vector2()
    assert(v1 == v2, "two default Vector2 should be equal")
    assert((v1 ~= v2) == false, "two default Vector2 should be equal")

    v1.x = 1
    assert(v1 ~= v2, "two different Vector2 should not be equal")
    assert((v1 == v2) == false, "these two Vector2 should not be equal")
    v2.x = 1
    assert(v1 == v2, "these two Vector2 should be equal")
    assert((v1 ~= v2) == false, "these two Vector2 should be equal")

    v1.y = 1
    assert(v1 ~= v2, "two different Vector2 should not be equal")
    assert((v1 == v2) == false, "these two Vector2 should not be equal")
    v2.y = 1
    assert(v1 == v2, "these two Vector2 should be equal")
    assert((v1 ~= v2) == false, "these two Vector2 should be equal")


    --[[vector3 to vector3]]
    local v3 = geometry.Vector3()
    local v4 = geometry.Vector3()
    assert(v3 == v4, "two default Vector3 should be equal")
    assert((v3 ~= v4) == false, "two default Vector3 should be equal")

    v3.x = 1
    assert(v3 ~= v4, "two different Vector3 should not be equal")
    assert((v3 == v4) == false, "these two Vector3 should not be equal")
    v4.x = 1
    assert(v3 == v4, "these two Vector3 should be equal")
    assert((v3 ~= v4) == false, "these two Vector3 should be equal")

    v3.y = 1
    assert(v3 ~= v4, "two different Vector3 should not be equal")
    assert((v3 == v4) == false, "these two Vector3 should not be equal")
    v4.y = 1
    assert(v3 == v4, "these two Vector3 should be equal")
    assert((v3 ~= v4) == false, "these two Vector3 should be equal")

    v3.z = 1
    assert(v3 ~= v4, "two different Vector3 should not be equal")
    assert((v3 == v4) == false, "these two Vector3 should not be equal")
    v4.z = 1
    assert(v3 == v4, "these two Vector3 should be equal")
    assert((v3 ~= v4) == false, "these two Vector3 should be equal")


    --[[cross-vector comparison]]
    -- these should always be false!
    v2 = geometry.Vector2()
    v3 = geometry.Vector3()
    assert((v2 == v3) == false, "Vector2 and Vector3 should never be equal")
    assert(v2 ~= v3, "Vector2 and Vector3 should never be equal")

    v2.z = 0
    assert((v2 == v3) == false, "Vector2 and Vector3 should never be equal")
    assert(v2 ~= v3, "Vector2 and Vector3 should never be equal")

end

function vectortest.testUnaryMinus()

    --[[testing with Vector2]]
    local v2 = geometry.Vector2()
    local r = -v2
    assert(r == v2, "the result of unary minus on 0,0 should be 0,0")

    v2 = geometry.Vector2(1, 1)
    r = -v2
    assert(r == geometry.Vector2(-1, -1), "the result of unary minus on 1,1 should be -1,-1")

    v2 = geometry.Vector2(-1, -1)
    r = -v2
    assert(r == geometry.Vector2(1, 1), "the result of unary minus on -1,-1 should be 1,1")


    --[[testing with Vector3]]
    local v3 = geometry.Vector3()
    local r = -v3
    assert(r == v3, "the result of unary minus on 0,0 should be 0,0")

    v3 = geometry.Vector3(1, 1, 1)
    r = -v3
    assert(r == geometry.Vector3(-1, -1, -1), "the result of unary minus on 1,1,1 should be -1,-1,-1")

    v3 = geometry.Vector3(-1, -1, -1)
    r = -v3
    assert(r == geometry.Vector3(1, 1, 1), "the result of unary minus on -1,-1,-1 should be 1,1,1")

end

function vectortest.testVector2MagnitudeAndSqrMagnitude()

    --[[0,0 to 0,0]]
    local origin = geometry.Vector2()
    local v2 = geometry.Vector2()
    assert(v2:magnitude(origin) == 0, "the magnitude of 0,0 to 0,0 wasn't 0")
    assert(v2:sqrMagnitude(origin) == 0, "the square magnitude of 0,0 to 0,0 wasn't 0")


    --[[0,0 to all negations of 5,5]]
    origin = geometry.Vector2()
    v2 = geometry.Vector2(5, 5)
    assert(v2:magnitude(origin) == math.sqrt(50), "the magnitude of 5,5 to 0,0 should be sqrt(50)")
    assert(v2:sqrMagnitude(origin) == 50, "the square magnitude of 5,5 to 0,0 should be 50")

    v2 = geometry.Vector2(-5, 5)
    assert(v2:magnitude(origin) == math.sqrt(50), "the magnitude of -5,5 to 0,0 should be sqrt(50)")
    assert(v2:sqrMagnitude(origin) == 50, "the square magnitude of -5,5 to 0,0 should be 50")

    v2 = geometry.Vector2(5, -5)
    assert(v2:magnitude(origin) == math.sqrt(50), "the magnitude of 5,-5 to 0,0 should be sqrt(50)")
    assert(v2:sqrMagnitude(origin) == 50, "the square magnitude of 5,-5 to 0,0 should be 50")

    v2 = geometry.Vector2(-5, -5)
    assert(v2:magnitude(origin) == math.sqrt(50), "the magnitude of -5,-5 to 0,0 should be sqrt(50)")
    assert(v2:sqrMagnitude(origin) == 50, "the square magnitude of -5,-5 to 0,0 should be 50")


    --[[1,1 to all negations of 2,2]]
    origin = geometry.Vector2(1, 1)
    v2 = geometry.Vector2(2, 2)
    assert(v2:magnitude(origin) == math.sqrt(2), "the magnitude of 2,2 to 1,1 should be sqrt(2)")
    assert(v2:sqrMagnitude(origin) == 2, "the square magnitude of 2,2 to 1,1 should be 2")

    v2 = geometry.Vector2(-2, 2)
    assert(v2:magnitude(origin) == math.sqrt(10), "the magnitude of -2,2 to 1,1 should be sqrt(10)")
    assert(v2:sqrMagnitude(origin) == 10, "the square magnitude of -2,2 to 1,1 should be 10")

    v2 = geometry.Vector2(2, -2)
    assert(v2:magnitude(origin) == math.sqrt(10), "the magnitude of 2,-2 to 1,1 should be sqrt(10)")
    assert(v2:sqrMagnitude(origin) == 10, "the square magnitude of 2,-2 to 1,1 should be 10")

    v2 = geometry.Vector2(-2, -2)
    assert(v2:magnitude(origin) == math.sqrt(18), "the magnitude of -2,-2 to 1,1 should be sqrt(18)")
    assert(v2:sqrMagnitude(origin) == 18, "the square magnitude of -2,-2 to 1,1 should be 18")

end

function vectortest.testVector3MagnitudeAndSqrMagnitude()

    --[[0,0,0 to 0,0,0]]
    local origin = geometry.Vector3()
    local v3 = geometry.Vector3()
    assert(v3:magnitude(origin) == 0, "the magnitude of 0,0,0 to 0,0,0 wasn't 0")
    assert(v3:sqrMagnitude(origin) == 0, "the square magnitude of 0,0,0 to 0,0,0 wasn't 0")


    --[[0,0,0 to all negations of 5,5,5]]
    origin = geometry.Vector3()
    v2 = geometry.Vector3(5, 5, 5)
    assert(v2:magnitude(origin) == math.sqrt(75), "the magnitude of 5,5,5 to 0,0,0 should be sqrt(75)")
    assert(v2:sqrMagnitude(origin) == 75, "the square magnitude of 5,5,5 to 0,0,0 should be 75")

    v2 = geometry.Vector3(-5, 5, -5)
    assert(v2:magnitude(origin) == math.sqrt(75), "the magnitude of -5,5,-5 to 0,0,0 should be sqrt(75)")
    assert(v2:sqrMagnitude(origin) == 75, "the square magnitude of -5,5,-5 to 0,0,0 should be 75")

    v2 = geometry.Vector3(5, -5, 5)
    assert(v2:magnitude(origin) == math.sqrt(75), "the magnitude of 5,-5,5 to 0,0,0 should be sqrt(75)")
    assert(v2:sqrMagnitude(origin) == 75, "the square magnitude of 5,-5,5 to 0,0,0 should be 75")

    v2 = geometry.Vector3(-5, -5, -5)
    assert(v2:magnitude(origin) == math.sqrt(75), "the magnitude of -5,-5,-5 to 0,0,0 should be sqrt(75)")
    assert(v2:sqrMagnitude(origin) == 75, "the square magnitude of -5,-5,-5 to 0,0,0 should be 75")


    --[[1,1,1 to all negations of 2,2,2]]
    origin = geometry.Vector3(1, 1,1)
    v2 = geometry.Vector3(2, 2, 2)
    assert(v2:magnitude(origin) == math.sqrt(3), "the magnitude of 2,2,2 to 1,1,1 should be sqrt(3)")
    assert(v2:sqrMagnitude(origin) == 3, "the square magnitude of 2,2,2 to 1,1,1 should be 3")

    v2 = geometry.Vector3(-2, 2, -2)
    assert(v2:magnitude(origin) == math.sqrt(19), "the magnitude of -2,2,-2 to 1,1,1 should be sqrt(19)")
    assert(v2:sqrMagnitude(origin) == 19, "the square magnitude of -2,2,-2 to 1,1,1 should be 19")

    v2 = geometry.Vector3(2, -2, 2)
    assert(v2:magnitude(origin) == math.sqrt(11), "the magnitude of 2,-2,2 to 1,1,1 should be sqrt(11)")
    assert(v2:sqrMagnitude(origin) == 11, "the square magnitude of 2,-2,2 to 1,1,1 should be 11")

    v2 = geometry.Vector3(-2, -2, -2)
    assert(v2:magnitude(origin) == math.sqrt(27), "the magnitude of -2,-2,-2 to 1,1,1 should be sqrt(27)")
    assert(v2:sqrMagnitude(origin) == 27, "the square magnitude of -2,-2,-2 to 1,1,1 should be 27")

end

function vectortest.testVectorToString()

    --[[testing Vector2]]
    local v2 = geometry.Vector2()
    assert(tostring(v2) == "{x=0.00, y=0.00}")

    v2 = geometry.Vector2(1, 2)
    assert(tostring(v2) == "{x=1.00, y=2.00}")

    v2 = geometry.Vector2(1.1, 2.2)
    assert(tostring(v2) == "{x=1.10, y=2.20}")

    v2 = geometry.Vector2(3.33, 4.44)
    assert(tostring(v2) == "{x=3.33, y=4.44}")

    -- account for rounding
    v2 = geometry.Vector2(5.555, 6.666)
    assert(tostring(v2) == "{x=5.55, y=6.67}")

    -- negative, and negative rounding
    v2 = geometry.Vector2(-5.00, -8.009)
    assert(tostring(v2) == "{x=-5.00, y=-8.01}")


    --[[testing Vector3]]
    local v3 = geometry.Vector3()
    assert(tostring(v3) == "{x=0.00, y=0.00, z=0.00}")

    v3 = geometry.Vector3(1, 2, 3)
    assert(tostring(v3) == "{x=1.00, y=2.00, z=3.00}")

    v3 = geometry.Vector3(1.1, 2.2, 3.3)
    assert(tostring(v3) == "{x=1.10, y=2.20, z=3.30}")

    v3 = geometry.Vector3(3.33, 4.44, 5.55)
    assert(tostring(v3) == "{x=3.33, y=4.44, z=5.55}")

    -- account for rounding
    v3 = geometry.Vector3(5.555, 6.666, 7.777)
    assert(tostring(v3) == "{x=5.55, y=6.67, z=7.78}")

    -- negative, and negative rounding
    v3 = geometry.Vector3(-5.00, -8.009, -12.005)
    assert(tostring(v3) == "{x=-5.00, y=-8.01, z=-12.01}")

end

return vectortest
