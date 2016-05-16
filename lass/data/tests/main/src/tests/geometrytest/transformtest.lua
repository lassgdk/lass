local geometry = require("lass.geometry")
local helpers = require("tests.geometrytest.helpers")
local class = require("lass.class")
local turtlemode = require("turtlemode")

local transformtest = turtlemode.testModule()
local assertEqual = turtlemode.assertEqual
local assertNotEqual = turtlemode.assertNotEqual


function transformtest:testTransformCreation()

    --[[incorrect creation]]
    helpers.assertIncorrectRunner("creation", geometry.Transform, "transform", {"position", "rotation", "size"})
    helpers.assertIncorrectRunner("setting", geometry.Transform, "transform", {"position", "rotation"})
    helpers.assertIncorrectRunner("setting", geometry.Transform, "transform", {"size"},
                                  geometry.Vector3(1, 1, 1),
                                  {geometry.Vector3(-1, -1, -1), geometry.Vector3(0, 0, 0)})
    helpers.assertIncorrectRunner("setting", geometry.Transform, "transform",
                                  {{"size", "x"}, {"size", "y"}, {"size", "z"}}, nil, {0, -1})

    --[[basic creation]]
    local t = geometry.Transform()

    assert(class.instanceof(t, geometry.Transform), "transform should be valid as a transform")

    assertEqual(t.position.x, 0, "transform x position didn't default to 0")
    assertEqual(t.position.y, 0, "transform y position didn't default to 0")
    assertEqual(t.position.z, 0, "transform z position didn't default to 0")

    assertEqual(t.rotation, 0, "transform rotation didn't default to 0")

    assertEqual(t.size.x, 1, "transform x size didn't default to 1")
    assertEqual(t.size.y, 1, "transform y size didn't default to 1")
    assertEqual(t.size.z, 1, "transform z size didn't default to 1")


    --[[testing creation with table]]
    local values = {position=geometry.Vector3(1, 2, 3), rotation=45, size=geometry.Vector3(10, 20, 30)}
    t = geometry.Transform(values)

    assertEqual(t.position.x, 1)
    assertEqual(t.position.y, 2)
    assertEqual(t.position.z, 3)

    assertEqual(t.rotation, 45)

    assertEqual(t.size.x, 10)
    assertEqual(t.size.y, 20)
    assertEqual(t.size.z, 30)


    --[[testing position]]
    t = geometry.Transform({})
    assertEqual(t.position.x, 0)
    assertEqual(t.position.y, 0)
    assertEqual(t.position.z, 0)

    -- values in table should be ignored
    t = geometry.Transform({1, 1, 1})
    assertEqual(t.position.x, 0)
    assertEqual(t.position.y, 0)
    assertEqual(t.position.z, 0)

    t = geometry.Transform({x=1, y=2, z=3})
    assertEqual(t.position.x, 1)
    assertEqual(t.position.y, 2)
    assertEqual(t.position.z, 3)


    --[[testing rotation]]
    t = geometry.Transform(nil, 0)
    assertEqual(t.rotation, 0)
    t = geometry.Transform(nil, 1)
    assertEqual(t.rotation, 1)
    t = geometry.Transform(nil, 359)
    assertEqual(t.rotation, 359)

    t = geometry.Transform(nil, 360)
    assertEqual(t.rotation, 0)
    t = geometry.Transform(nil, 361)
    assertEqual(t.rotation, 1)
    t = geometry.Transform(nil, -1)
    assertEqual(t.rotation, 359)


    --[[testing size]]
    t = geometry.Transform(nil, nil, {})
    assertEqual(t.size.x, 1)
    assertEqual(t.size.y, 1)
    assertEqual(t.size.z, 1)

    -- values in table should be ignored
    t = geometry.Transform(nil, nil, {0, 0, 0})
    assertEqual(t.size.x, 1)
    assertEqual(t.size.y, 1)
    assertEqual(t.size.z, 1)

    t = geometry.Transform(nil, nil, {x=2, y=3, z=4})
    assertEqual(t.size.x, 2)
    assertEqual(t.size.y, 3)
    assertEqual(t.size.z, 4)

    t = geometry.Transform(nil, nil, {x=2})
    assertEqual(t.size.x, 2)
    assertEqual(t.size.y, 1)
    assertEqual(t.size.z, 1)

    t = geometry.Transform(nil, nil, {y=2})
    assertEqual(t.size.x, 1)
    assertEqual(t.size.y, 2)
    assertEqual(t.size.z, 1)

    t = geometry.Transform(nil, nil, {z=2})
    assertEqual(t.size.x, 1)
    assertEqual(t.size.y, 1)
    assertEqual(t.size.z, 2)
    
end

function transformtest:testTransformCreationWithTransform()

    --[[basic creation]]
    local t1 = geometry.Transform()
    local t2 = geometry.Transform(t1)

    assertEqual(t2.position.x, 0, "transform x position didn't default to 0")
    assertEqual(t2.position.y, 0, "transform y position didn't default to 0")
    assertEqual(t2.position.z, 0, "transform z position didn't default to 0")

    assertEqual(t2.rotation, 0, "transform rotation didn't default to 0")

    assertEqual(t2.size.x, 1, "transform x size didn't default to 1")
    assertEqual(t2.size.y, 1, "transform y size didn't default to 1")
    assertEqual(t2.size.z, 1, "transform z size didn't default to 1")


    --[[basic unpacking]]
    t1 = geometry.Transform(geometry.Vector3(1, 1, 1), 1, geometry.Vector3(2, 2, 2))
    t2 = geometry.Transform(t1)

    assertEqual(t2.position.x, 1)
    assertEqual(t2.position.y, 1)
    assertEqual(t2.position.y, 1)

    assertEqual(t2.rotation, 1)

    assertEqual(t2.size.x, 2)
    assertEqual(t2.size.y, 2)
    assertEqual(t2.size.y, 2)


    --[[alt signature reliance]]

    t1 = geometry.Transform(nil, 1, geometry.Vector3(2, 2, 2))
    -- rotation and size should be overwritten by t1.rotation and .size
    t2 = geometry.Transform(t1, 5, geometry.Vector3(5, 5, 5))

    assertEqual(t2.rotation, 1)
    assertEqual(t2.size.x, 2)
    assertEqual(t2.size.y, 2)
    assertEqual(t2.size.z, 2)

    t1 = geometry.Transform(nil, 1, geometry.Vector3(2, 2, 2))
    -- this call shouldn't fail even though the given rotation is improper
    geometry.Transform(t1, "")
    -- ditto for size
    geometry.Transform(t1, nil, "")

end

function transformtest:testTransformCreationWithVector2()

    --[[basic creation]]
    local t = geometry.Transform(geometry.Vector2(), nil, geometry.Vector2(1, 1))

    assertEqual(t.position.x, 0, "transform x position didn't default to 0")
    assertEqual(t.position.y, 0, "transform y position didn't default to 0")
    assertEqual(t.position.z, 0, "transform z position didn't default to 0")

    assertEqual(t.rotation, 0, "transform rotation didn't default to 0")

    assertEqual(t.size.x, 1)
    assertEqual(t.size.y, 1)
    assertEqual(t.size.z, 1)


    --[[using values]]
    t = geometry.Transform(geometry.Vector2(1, 1), nil, geometry.Vector2(2, 2))

    assertEqual(t.position.x, 1)
    assertEqual(t.position.y, 1)
    assertEqual(t.position.z, 0)

    assertEqual(t.size.x, 2)
    assertEqual(t.size.y, 2)
    assertEqual(t.size.z, 1)

end

return transformtest