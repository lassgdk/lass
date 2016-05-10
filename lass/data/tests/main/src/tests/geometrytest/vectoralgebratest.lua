local geometry = require("lass.geometry")
local helpers = require("tests.geometrytest.helpers")
local class = require("lass.class")
local turtlemode = require("turtlemode")

local vectoralgebratest = turtlemode.testModule()
local assertEqual = turtlemode.assertEqual
local assertNotEqual = turtlemode.assertNotEqual

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

function vectoralgebratest:assertIncorrectVectorAlgebra()
    -- tests all possible cases of Vector2/3 algebra that should crash
    _assertIncorrectVectorAlgebra("Vector2", geometry.Vector2)
    _assertIncorrectVectorAlgebra("Vector3", geometry.Vector3)
end


function vectoralgebratest:testVector2Add()
    -- testing accessing Vector2.__add is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v1 = geometry.Vector2()
    local r = v1 + v1
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assertEqual(class.instanceof(r, geometry.Vector3), false, "Vector2 shouldn't be valid as Vector3")


    --[[operator order]]
    v1 = geometry.Vector2(1, 5)
    local v2 = geometry.Vector2(2, 10)

    r = v1 + v1
    assertEqual(r.x, 2)
    assertEqual(r.y, 10)

    r = v1 + v2
    assertEqual(r.x, 3)
    assertEqual(r.y, 15)

    r = v2 + v1
    assertEqual(r.x, 3)
    assertEqual(r.y, 15)


    --[[using tables]]
    v1 = geometry.Vector2(10, 20)
    local t = {x=100, y=200, z=300}

    r = v1 + t
    assertEqual(r.x, 110)
    assertEqual(r.y, 220)
    assertEqual(r.z, nil, "Vector2 shouldn't have a z value")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assertEqual(class.instanceof(r, geometry.Vector3), false, "Vector2 shouldn't be valid as Vector3")

    r = t + v1
    assertEqual(r.x, 110)
    assertEqual(r.y, 220)
    assertEqual(r.z, nil, "Vector2 shouldn't have a z value")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assertEqual(class.instanceof(r, geometry.Vector3), false, "Vector2 shouldn't be valid as Vector3")

end

function vectoralgebratest:testVector3Add()
    -- testing accessing Vector3.__add is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v1 = geometry.Vector3()
    local r = v1 + v1
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)
    assertEqual(r.z, 0)
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")


    --[[operator order]]
    v1 = geometry.Vector3(1, 5, 10)
    local v2 = geometry.Vector3(2, 10, 20)

    r = v1 + v1
    assertEqual(r.x, 2)
    assertEqual(r.y, 10)
    assertEqual(r.z, 20)

    r = v1 + v2
    assertEqual(r.x, 3)
    assertEqual(r.y, 15)
    assertEqual(r.z, 30)

    r = v2 + v1
    assertEqual(r.x, 3)
    assertEqual(r.y, 15)
    assertEqual(r.z, 30)


    --[[using tables]]
    v1 = geometry.Vector3(10, 20, 30)
    local t = {x=100, y=200, z=300}

    r = v1 + t
    assertEqual(r.x, 110)
    assertEqual(r.y, 220)
    assertEqual(r.z, 330)
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")

    r = t + v1
    assertEqual(r.x, 110)
    assertEqual(r.y, 220)
    assertEqual(r.z, 330)
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")

end

function vectoralgebratest:testVector2And3Add()
    -- test vector addition that crosses vector 2 and 3

    --[[basic usage]]
    local v2 = geometry.Vector2()
    local v3 = geometry.Vector3()

    local r = v2 + v3
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "addition with Vector3 didn't return Vector3")
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)
    assertEqual(r.z, 0)

    r = v3 + v2
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "addition with Vector3 didn't return Vector3")
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)
    assertEqual(r.z, 0)


    --[[operator order]]
    v2 = geometry.Vector2(1, 5)
    v3 = geometry.Vector3(10, 20, 30)

    r = v2 + v3
    assertEqual(r.x, 11)
    assertEqual(r.y, 25)
    assertEqual(r.z, 30)

    r = v3 + v2
    assertEqual(r.x, 11)
    assertEqual(r.y, 25)
    assertEqual(r.z, 30)

end

function vectoralgebratest:testVector2Subtract()
    -- testing accessing Vector2.__sub is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v1 = geometry.Vector2()
    local r = v1 - v1
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)


    --[[operator order]]
    v1 = geometry.Vector2(1, 5)
    local v2 = geometry.Vector2(2, 10)

    r = v1 - v1
    assertEqual(r.x, 0)
    assertEqual(r.y, 0)

    r = v1 - v2
    assertEqual(r.x, -1)
    assertEqual(r.y, -5)

    r = v2 - v1
    assertEqual(r.x, 1)
    assertEqual(r.y, 5)


    --[[using tables]]
    v1 = geometry.Vector2(10, 20, 30)
    local t = {x=11, y=22, z=33}

    r = v1 - t
    assertEqual(r.x, -1)
    assertEqual(r.y, -2)
    assertEqual(r.z, nil, "Vector2 shouldn't have a z value")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assertEqual(class.instanceof(r, geometry.Vector3), false, "Vector3 shouldn't be valid as Vector3")

    r = t - v1
    assertEqual(r.x, 1)
    assertEqual(r.y, 2)
    assertEqual(r.z, nil, "Vector2 shouldn't have a z value")
    assert(class.instanceof(r, geometry.Vector2), "Vector2 should be valid as Vector2")
    assertEqual(class.instanceof(r, geometry.Vector3), false, "Vector2 shouldn't be valid as Vector3")

end

function vectoralgebratest:testVector3Subtract()
    -- testing accessing Vector3.__sub is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v1 = geometry.Vector3()
    local r = v1 - v1
    assert(r.x == 0)
    assert(r.y == 0)
    assert(r.z == 0)


    --[[operator order]]
    v1 = geometry.Vector3(1, 5, 10)
    local v2 = geometry.Vector3(2, 10, 20)

    r = v1 - v1
    assert(r.x == 0)
    assert(r.y == 0)
    assert(r.z == 0)

    r = v1 - v2
    assert(r.x == -1)
    assert(r.y == -5)
    assert(r.z == -10)

    r = v2 - v1
    assert(r.x == 1)
    assert(r.y == 5)
    assert(r.z == 10)


    --[[using tables]]
    v1 = geometry.Vector3(10, 20, 30)
    local t = {x=11, y=22, z=33}

    r = v1 - t
    assert(r.x == -1)
    assert(r.y == -2)
    assert(r.z == -3)
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")

    r = t - v1
    assert(r.x == 1)
    assert(r.y == 2)
    assert(r.z == 3)
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "Vector3 should be valid as Vector3")

end

function vectoralgebratest:testVector2And3Subtract()
    -- test vector subtraction that crosses vector 2 and 3

    --[[basic usage]]
    local v2 = geometry.Vector2()
    local v3 = geometry.Vector3()

    local r = v2 - v3
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "subtraction with Vector3 didn't return Vector3")
    assert(r.x == 0)
    assert(r.y == 0)
    assert(r.z == 0)

    r = v3 - v2
    assert(class.instanceof(r, geometry.Vector2), "Vector3 should be valid as Vector2")
    assert(class.instanceof(r, geometry.Vector3), "subtraction with Vector3 didn't return Vector3")
    assert(r.x == 0)
    assert(r.y == 0)
    assert(r.z == 0)


    --[[operator order]]
    v2 = geometry.Vector2(1, 5)
    v3 = geometry.Vector3(10, 20, 30)

    r = v2 - v3
    assert(r.x == -9)
    assert(r.y == -15)
    assert(r.z == -30)

    r = v3 - v2
    assert(r.x == 9)
    assert(r.y == 15)
    assert(r.z == 30)

end

function vectoralgebratest:testVector2Multiply()
    -- testing accessing Vector2.__mul is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v = geometry.Vector2()
    local r = v * 0
    assert(r.x == 0)
    assert(r.y == 0)


    --[[operator order]]
    v = geometry.Vector2(1, 2)

    r = v * 2
    assert(r.x == 2)
    assert(r.y == 4)

    r = 3 * v
    assert(r.x == 3)
    assert(r.y == 6)

end

function vectoralgebratest:testVector3Multiply()
    -- testing accessing Vector3.__mul is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v = geometry.Vector3()
    local r = v * 0
    assert(r.x == 0)
    assert(r.y == 0)
    assert(r.z == 0)


    --[[operator order]]
    v = geometry.Vector3(1, 2, 3)

    r = v * 2
    assert(r.x == 2)
    assert(r.y == 4)
    assert(r.z == 6)

    r = 3 * v
    assert(r.x == 3)
    assert(r.y == 6)
    assert(r.z == 9)

end

function vectoralgebratest:testVector2Divide()
    -- testing accessing Vector2.__div is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v = geometry.Vector2()
    local r = v / 1
    assert(r.x == 0)
    assert(r.y == 0)


    --[[operator order]]
    v = geometry.Vector2(4, 8)

    r = v / 2
    assert(r.x == 2)
    assert(r.y == 4)

    r = 4 / v
    assert(r.x == 1)
    assert(r.y == 2)

end

function vectoralgebratest:testVector3Divide()
    -- testing accessing Vector3.__div is intentionally not covered, as it is not the proper usage

    --[[basic usage]]
    local v = geometry.Vector3()
    local r = v / 1
    assert(r.x == 0)
    assert(r.y == 0)
    assert(r.z == 0)


    --[[operator order]]
    v = geometry.Vector3(4, 8, 16)

    r = v / 2
    assert(r.x == 2)
    assert(r.y == 4)
    assert(r.z == 8)

    r = 4 / v
    assert(r.x == 1)
    assert(r.y == 2)
    assert(r.z == 4)

end

return vectoralgebratest
