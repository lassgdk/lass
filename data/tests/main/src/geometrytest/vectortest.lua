local geometry = require("lass.geometry")
local helpers = require("geometrytest.helpers")
local class = require("lass.class")

local vectortest = {}

-- [[notes]]
-- cross multiplication / division of Vector2 and 3 is not tested, as it is not possible
-- a spread of different numbers is often used to ensure unique results for each individual test


local function _assertIncorrectVectorAlgebra(vectorName, vector)

    for i, badValue in ipairs({{}, 1, "1", false, math.huge, -math.huge, math.huge / math.huge}) do
        local operands = {vector, badValue}

        -- goes through (vector, badValue) then (badValue, vector)
        for first, second in pairs({2, 1}) do

            if i ~= 1 then
                local success = pcall(function() return operands[first] + operands[second] end)
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

function vectortest.assertIncorrectVectorAlgebra()
    -- tests all possible cases of Vector2/3 algebra that should crash
    _assertIncorrectVectorAlgebra("Vector2", geometry.Vector2)
    _assertIncorrectVectorAlgebra("Vector3", geometry.Vector3)
end

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


function vectortest.testVector2Add()
    -- testing accessing Vector2.__add is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v1 = geometry.Vector2()
    local r = v1 + v1
    assert(r.x == 0, "0 + 0 didn't equal 0")
    assert(r.y == 0, "0 + 0 didn't equal 0")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3) == false, "Vector2 shouldn't be valid as Vector3")


    --[[operator order]]
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


    --[[using tables]]
    v1 = geometry.Vector2(10, 20)
    local t = {x=100, y=200, z=300}

    r = v1 + t
    assert(r.x == 110, "10 + 100 didn't become 110")
    assert(r.y == 220, "20 + 200 didn't become 220")
    assert(r.z == nil, "Vector2 shouldn't have a z value")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3) == false, "Vector2 shouldn't be valid as Vector3")

    r = t + v1
    assert(r.x == 110, "100 + 10 didn't become 110")
    assert(r.y == 220, "200 + 20 didn't become 220")
    assert(r.z == nil, "Vector2 shouldn't have a z value")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3) == false, "Vector2 shouldn't be valid as Vector3")


end

function vectortest.testVector3Add()
    -- testing accessing Vector3.__add is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v1 = geometry.Vector3()
    local r = v1 + v1
    assert(r.x == 0, "0 + 0 didn't equal 0")
    assert(r.y == 0, "0 + 0 didn't equal 0")
    assert(r.z == 0, "0 + 0 didn't equal 0")


    --[[operator order]]
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


    --[[using tables]]
    v1 = geometry.Vector3(10, 20, 30)
    local t = {x=100, y=200, z=300}

    r = v1 + t
    assert(r.x == 110, "10 + 100 didn't become 110")
    assert(r.y == 220, "20 + 200 didn't become 220")
    assert(r.z == 330, "30 + 300 didn't become 330")
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")

    r = t + v1
    assert(r.x == 110, "100 + 10 didn't become 110")
    assert(r.y == 220, "200 + 20 didn't become 220")
    assert(r.z == 330, "300 + 30 didn't become 330")
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")

end

function vectortest.testVector2And3Add()
    -- test vector addition that crosses vector 2 and 3

    --[[basic usage]]
    local v2 = geometry.Vector2()
    local v3 = geometry.Vector3()

    local r = v2 + v3
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "addition with Vector3 didn't return Vector3")
    assert(r.x == 0, "0 + 0 didn't equal 0")
    assert(r.y == 0, "0 + 0 didn't equal 0")
    assert(r.z == 0, "0 + 0 didn't equal 0")

    r = v3 + v2
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "addition with Vector3 didn't return Vector3")
    assert(r.x == 0, "0 + 0 didn't equal 0")
    assert(r.y == 0, "0 + 0 didn't equal 0")
    assert(r.z == 0, "0 + 0 didn't equal 0")


    --[[operator order]]
    v2 = geometry.Vector2(1, 5)
    v3 = geometry.Vector3(10, 20, 30)

    r = v2 + v3
    assert(r.x == 11, "1 + 10 didn't equal 11")
    assert(r.y == 25, "5 + 20 didn't equal 25")
    assert(r.z == 30, "0 + 30 didn't equal 30")

    r = v3 + v2
    assert(r.x == 11, "10 + 1 didn't equal 11")
    assert(r.y == 25, "20 + 5 didn't equal 25")
    assert(r.z == 30, "30 + 0 didn't equal 30")

end

function vectortest.testVector2Subtract()
    -- testing accessing Vector2.__sub is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v1 = geometry.Vector2()
    local r = v1 - v1
    assert(r.x == 0, "0 - 0 didn't equal 0")
    assert(r.y == 0, "0 - 0 didn't equal 0")


    --[[operator order]]
    v1 = geometry.Vector2(1, 5)
    local v2 = geometry.Vector2(2, 10)

    r = v1 - v1
    assert(r.x == 0, "1 - 1 didn't become 0")
    assert(r.y == 0, "5 - 5 didn't become 0")

    r = v1 - v2
    assert(r.x == -1, "1 - 2 didn't become -1")
    assert(r.y == -5, "5 - 10 didn't become -5")

    r = v2 - v1
    assert(r.x == 1, "2 - 1 didn't become 1")
    assert(r.y == 5, "10 - 5 didn't become 5")


    --[[using tables]]
    v1 = geometry.Vector2(10, 20, 30)
    local t = {x=11, y=22, z=33}

    r = v1 - t
    assert(r.x == -1, "10 - 11 didn't become -1")
    assert(r.y == -2, "20 - 22 didn't become -2")
    assert(r.z == nil, "Vector2 shouldn't have a z value")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3) == false, "Vector3 shouldn't be valid as Vector3")

    r = t - v1
    assert(r.x == 1, "11 - 10 didn't become 1")
    assert(r.y == 2, "22 - 20 didn't become 2")
    assert(r.z == nil, "Vector2 shouldn't have a z value")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3) == false, "Vector2 shouldn't be valid as Vector3")

end

function vectortest.testVector3Subtract()
    -- testing accessing Vector3.__sub is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v1 = geometry.Vector3()
    local r = v1 - v1
    assert(r.x == 0, "0 - 0 didn't equal 0")
    assert(r.y == 0, "0 - 0 didn't equal 0")
    assert(r.z == 0, "0 - 0 didn't equal 0")


    --[[operator order]]
    v1 = geometry.Vector3(1, 5, 10)
    local v2 = geometry.Vector3(2, 10, 20)

    r = v1 - v1
    assert(r.x == 0, "1 - 1 didn't become 0")
    assert(r.y == 0, "5 - 5 didn't become 0")
    assert(r.z == 0, "10 - 10 didn't become 0")

    r = v1 - v2
    assert(r.x == -1, "1 - 2 didn't become -1")
    assert(r.y == -5, "5 - 10 didn't become -5")
    assert(r.z == -10, "10 - 20 didn't become -10")

    r = v2 - v1
    assert(r.x == 1, "2 - 1 didn't become 1")
    assert(r.y == 5, "10 - 5 didn't become 5")
    assert(r.z == 10, "20 - 10 didn't become 10")


    --[[using tables]]
    v1 = geometry.Vector3(10, 20, 30)
    local t = {x=11, y=22, z=33}

    r = v1 - t
    assert(r.x == -1, "10 - 11 didn't become -1")
    assert(r.y == -2, "20 - 22 didn't become -2")
    assert(r.z == -3, "30 - 33 didn't become -3")
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")

    r = t - v1
    assert(r.x == 1, "11 - 10 didn't become 1")
    assert(r.y == 2, "22 - 20 didn't become 2")
    assert(r.z == 3, "33 - 30 didn't become 3")
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")

end

function vectortest.testVector2And3Subtract()
    -- test vector subtraction that crosses vector 2 and 3

    --[[basic usage]]
    local v2 = geometry.Vector2()
    local v3 = geometry.Vector3()

    local r = v2 - v3
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "subtraction with Vector3 didn't return Vector3")
    assert(r.x == 0, "0 - 0 didn't equal 0")
    assert(r.y == 0, "0 - 0 didn't equal 0")
    assert(r.z == 0, "0 - 0 didn't equal 0")

    r = v3 - v2
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "subtraction with Vector3 didn't return Vector3")
    assert(r.x == 0, "0 - 0 didn't equal 0")
    assert(r.y == 0, "0 - 0 didn't equal 0")
    assert(r.z == 0, "0 - 0 didn't equal 0")


    --[[operator order]]
    v2 = geometry.Vector2(1, 5)
    v3 = geometry.Vector3(10, 20, 30)

    r = v2 - v3
    assert(r.x == -9, "1 - 10 didn't equal -9")
    assert(r.y == -15, "5 - 20 didn't equal -15")
    assert(r.z == -30, "0 - 30 didn't equal -30")

    r = v3 - v2
    assert(r.x == 9, "10 - 1 didn't equal 9")
    assert(r.y == 15, "20 - 5 didn't equal 15")
    assert(r.z == 30, "30 - 0 didn't equal 30")

end

function vectortest.testVector2Multiply()
    -- testing accessing Vector2.__mul is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v = geometry.Vector2()
    local r = v * 0
    assert(r.x == 0, "0 * 0 didn't equal 0")
    assert(r.y == 0, "0 * 0 didn't equal 0")


    --[[operator order]]
    v = geometry.Vector2(1, 2)

    r = v * 2
    assert(r.x == 2, "1 * 2 didn't become 2")
    assert(r.y == 4, "2 * 2 didn't become 4")

    r = 3 * v
    assert(r.x == 3, "3 * 1 didn't become 3")
    assert(r.y == 6, "3 * 2 didn't become 6")

end

function vectortest.testVector3Multiply()
    -- testing accessing Vector3.__mul is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v = geometry.Vector3()
    local r = v * 0
    assert(r.x == 0, "0 * 0 didn't equal 0")
    assert(r.y == 0, "0 * 0 didn't equal 0")
    assert(r.z == 0, "0 * 0 didn't equal 0")


    --[[operator order]]
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

function vectortest.testVector2Divide()
    -- testing accessing Vector2.__div is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v = geometry.Vector2()
    local r = v / 1
    assert(r.x == 0, "0 / 1 didn't equal 0")
    assert(r.y == 0, "0 / 1 didn't equal 0")


    --[[operator order]]
    v = geometry.Vector2(4, 8)

    r = v / 2
    assert(r.x == 2, "4 / 2 didn't become 2")
    assert(r.y == 4, "8 / 2 didn't become 4")

    r = 4 / v
    assert(r.x == 1, "4 / 4 didn't become 1")
    assert(r.y == 2, "8 / 4 didn't become 2")

end

function vectortest.testVector3Divide()
    -- testing accessing Vector3.__div is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v = geometry.Vector3()
    local r = v / 1
    assert(r.x == 0, "0 / 1 didn't equal 0")
    assert(r.y == 0, "0 / 1 didn't equal 0")
    assert(r.z == 0, "0 / 1 didn't equal 0")


    --[[operator order]]
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

return vectortest
