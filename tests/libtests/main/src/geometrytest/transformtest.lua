local geometry = require("lass.geometry")
local helpers = require("geometrytest.helpers")

transformtest = {}


function transformtest.testTransformCreation()

    --[[incorrect creation]]
    helpers.assertIncorrectCreation(geometry.Circle, "transform", {"position", "rotation", "size"})


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

function transformtest.testTransformCreationWithTransform()

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

return transformtest