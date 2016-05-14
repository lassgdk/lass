local lass = require("lass")
local geometry = require("lass.geometry")
local turtlemode = require("turtlemode")
local assertLen, assertEqual, assertNotEqual =
    turtlemode.assertLen,
    turtlemode.assertEqual,
    turtlemode.assertNotEqual
local helpers = require("tests.coretest.helpers")

local GameEntityTest = turtlemode.testModule()

function GameEntityTest:createEntity(scene, name, transform, parent)
    return lass.GameEntity(transform, parent)
end

--scene is actually nil in this case because there's no fixture for it.
--however, subclasses like GameObjectTest may define one

function GameEntityTest:testChildren(scene)

    local object = self:createEntity(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)
    local grandchild = self:createEntity(scene, "test grandchild", nil, child)
    local greatGrandchild = self:createEntity(scene, "test g-grandchild", nil, grandchild)

    assertLen(object.children, 1)
    assertEqual(helpers.numTreeNodes(object), 3)

    assertLen(child.children, 1)
    assertEqual(helpers.numTreeNodes(child), 2)

    assertLen(grandchild.children, 1)
    assertEqual(helpers.numTreeNodes(grandchild), 1)

    assertLen(greatGrandchild.children, 0)
    assertEqual(helpers.numTreeNodes(greatGrandchild), 0)
end

function GameEntityTest:testGlobalTransformGetters(scene)

    --[[setup]]
    -- position, rotation, size
    local object = self:createEntity(
        scene,
        "test",
        geometry.Transform(geometry.Vector3(10, 20, 30), 90, geometry.Vector3(2, 3, 4))
    )
    local child = self:createEntity(
        scene,
        "test child",
        geometry.Transform(geometry.Vector3(5, 15, 25), 180, geometry.Vector3(5, 6, 7)),
        object
    )
    
    local gt = child.globalTransform
    assertEqual(gt.position, child.globalPosition)
    assertEqual(gt.rotation, child.globalRotation)
    assertEqual(gt.size, child.globalSize)
end

function GameEntityTest:testMove(scene)

    --[[setup]]
    local object = self:createEntity(scene, "test")

    assertEqual(object.transform.position, geometry.Vector3(0, 0, 0),
        "default object local position is incorrect")
    assertEqual(object.globalPosition, geometry.Vector3(0, 0, 0),
        "default object global position is incorrect")

    local child = self:createEntity(scene, "test child", nil, object)

    assertEqual(object.transform.position, geometry.Vector3(0, 0, 0),
        "default child local position is incorrect")
    assertEqual(object.globalPosition, geometry.Vector3(0, 0, 0),
        "default child global position is incorrect")


    --[[moving an object]]
    object:move(5, 5, 5)
    object:move(0, 1, 2)
    assertEqual(object.transform.position, geometry.Vector3(5, 6, 7))
    assertEqual(object.globalPosition, geometry.Vector3(5, 6, 7))

    object:move(-5, -6, -7)
    assertEqual(object.transform.position, geometry.Vector3(0, 0, 0))
    assertEqual(object.globalPosition, geometry.Vector3(0, 0, 0))


    --[[moving a child]]
    object:move(5, 5, 5)
    child:move(2, 1, -1)
    assertEqual(child.transform.position, geometry.Vector3(2, 1, -1))
    assertEqual(child.globalPosition, geometry.Vector3(7, 6, 4))

    object:move(-5, -5, -5)
    child:move(-2, -1, 1)
    assertEqual(child.transform.position, geometry.Vector3(0, 0, 0))
    assertEqual(child.globalPosition, geometry.Vector3(0, 0, 0))

end

function GameEntityTest:testMoveTo(scene)

    --[[setup]]
    local object = self:createEntity(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)

    --[[moving an object]]
    object:moveTo(-2, 10, 5)
    assertEqual(object.transform.position, geometry.Vector3(-2, 10, 5))
    assertEqual(object.globalPosition, geometry.Vector3(-2, 10, 5))

    object:moveTo(0, 0, 0)
    assertEqual(object.transform.position, geometry.Vector3(0, 0, 0))
    assertEqual(object.globalPosition, geometry.Vector3(0, 0, 0))


    --[[moving a child]]
    object:moveTo(10, 10, 10)
    child:moveTo(-2, 5, 10)
    assertEqual(child.transform.position, geometry.Vector3(-2, 5, 10))
    assertEqual(child.globalPosition, geometry.Vector3(8, 15, 20))

    object:moveTo(0, 0, 0)
    assertEqual(child.transform.position, geometry.Vector3(-2, 5, 10))
    assertEqual(child.globalPosition, geometry.Vector3(-2, 5, 10))

    child:moveTo(0, 0, 0)
    assertEqual(child.transform.position, geometry.Vector3(0, 0, 0))
    assertEqual(child.globalPosition, geometry.Vector3(0, 0, 0))


    --[[excluding the z parameter]]
    object:moveTo(0, 0, 10)

    object:moveTo(7, 8)
    assertEqual(object.transform.position, geometry.Vector3(7, 8, 10))
    assertEqual(object.globalPosition, geometry.Vector3(7, 8, 10))

    -- using a table for x
    object:moveTo({x = 2, y = 5})
    assertEqual(object.transform.position, geometry.Vector3(2, 5, 10))
    assertEqual(object.globalPosition, geometry.Vector3(2, 5, 10))



end

function GameEntityTest:testMoveGlobal(scene)

    --[[setup]]
    local object = self:createEntity(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)

    --[[moving an object]]
    object:moveGlobal(5, 5, 5)
    object:moveGlobal(0, 1, 2)
    assertEqual(object.transform.position, geometry.Vector3(5, 6, 7))
    assertEqual(object.globalPosition, geometry.Vector3(5, 6, 7))

    object:moveGlobal(-5, -6, -7)
    assertEqual(object.transform.position, geometry.Vector3(0, 0, 0))
    assertEqual(object.globalPosition, geometry.Vector3(0, 0, 0))


    --[[moving a child]]
    object:moveGlobal(5, 5, 5)
    child:moveGlobal(0, 1, 2)
    assertEqual(child.transform.position, geometry.Vector3(0, 1, 2))
    assertEqual(child.globalPosition, geometry.Vector3(5, 6, 7))

    object:moveGlobal(-5, -5, -5)
    assertEqual(child.transform.position, geometry.Vector3(0, 1, 2))
    assertEqual(child.globalPosition, geometry.Vector3(0, 1, 2))

    child:moveGlobal(0, -1, -2)
    assertEqual(child.transform.position, geometry.Vector3(0, 0, 0))
    assertEqual(child.globalPosition, geometry.Vector3(0, 0, 0))


    --[[moving a child accounting for a non-zero global transform]]
    object:moveTo(4, 5, 6)
    object:resize(1, 1, 1)
    object:rotateTo(180)
    child:moveGlobal(6, 15, 24)
    assertEqual(child.transform.position, geometry.Vector3(-3, -7.5, 12))
    assertEqual(child.globalPosition, geometry.Vector3(10, 20, 30))

    object:resize(-1.5, -1.5, -1.5) --size is now 0.5
    object:rotateTo(90)
    child:moveGlobal(-3.25, 0.5, 6)
    assertEqual(child.transform.position, geometry.Vector3(-4, -14, 24))
    assertEqual(child.globalPosition, geometry.Vector3(-3, 7, 18))

    object:resize(0.5, 0.5, 0.5) --size is now 1
    object:rotateTo(270)
    child:moveGlobal(-18, -1, -30)
    assertEqual(child.transform.position, geometry.Vector3(-5, 4, -6))
    assertEqual(child.globalPosition, geometry.Vector3(0, 0, 0))

end

function GameEntityTest:testMoveToGlobal(scene)

    --[[setup]]
    local object = self:createEntity(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)


    --[[moving an object]]
    object:moveToGlobal(-2, 10, 15)
    assertEqual(object.transform.position, geometry.Vector3(-2, 10, 15))
    assertEqual(object.globalPosition, geometry.Vector3(-2, 10, 15))

    object:moveToGlobal(0, 0, 0)
    assertEqual(object.transform.position, geometry.Vector3(0, 0, 0))
    assertEqual(object.globalPosition, geometry.Vector3(0, 0, 0))


    --[[moving a child]]
    object:moveToGlobal(-2, 10, 20)
    child:moveToGlobal(5, 5, 20)
    assertEqual(child.transform.position, geometry.Vector3(7, -5, 0))
    assertEqual(child.globalPosition, geometry.Vector3(5, 5, 20))

    object:moveToGlobal(0, 0, 0)
    assertEqual(child.transform.position, geometry.Vector3(7, -5, 0))
    assertEqual(child.globalPosition, geometry.Vector3(7, -5, 0))

    child:moveToGlobal(0, 0, 0)
    assertEqual(child.transform.position, geometry.Vector3(0, 0, 0))
    assertEqual(child.globalPosition, geometry.Vector3(0, 0, 0))


    --[[moving a child accounting for a non-zero global transform]]
    object:moveTo(4, 5, 6)
    object:resize(1, 1, 1)
    object:rotateTo(180)
    child:moveToGlobal(10, 20, 30)
    assertEqual(child.transform.position, geometry.Vector3(-3, -7.5, 12))
    assertEqual(child.globalPosition, geometry.Vector3(10, 20, 30))

    object:resize(-1.5, -1.5, -1.5) --size is now 0.5
    object:rotateTo(90)
    child:moveToGlobal(-3, 7, 18)
    assertEqual(child.transform.position, geometry.Vector3(-4, -14, 24))
    assertEqual(child.globalPosition, geometry.Vector3(-3, 7, 18))

    object:resize(0.5, 0.5, 0.5) --size is now 1
    object:rotateTo(270)
    child:moveToGlobal(0, 0, 0)
    assertEqual(child.transform.position, geometry.Vector3(-5, 4, -6))
    assertEqual(child.globalPosition, geometry.Vector3(0, 0, 0))

end

function GameEntityTest:testResize(scene)

    --[[setup]]
    local object = self:createEntity(scene, "test")

    assertEqual(object.transform.size, geometry.Vector3(1, 1, 1))
    assertEqual(object.globalSize, geometry.Vector3(1, 1, 1))


    --[[GameEntity.resize]]
    object:resize(1, 1, 1)
    assertEqual(object.transform.size, geometry.Vector3(2, 2, 2))
    assertEqual(object.globalSize, geometry.Vector3(2, 2, 2))

    object:resize(5, 5, 5)
    assertEqual(object.transform.size, geometry.Vector3(7, 7, 7))
    assertEqual(object.globalSize, geometry.Vector3(7, 7, 7))

    object:resize(2, 4, 7)
    assertEqual(object.transform.size, geometry.Vector3(9, 11, 14))
    assertEqual(object.globalSize, geometry.Vector3(9, 11, 14))

    object:resize(-2, -4, -7)
    assertEqual(object.transform.size, geometry.Vector3(7, 7, 7))
    assertEqual(object.globalSize, geometry.Vector3(7, 7, 7))

    object:resize(-6, -5, -4)
    assertEqual(object.transform.size, geometry.Vector3(1, 2, 3))
    assertEqual(object.globalSize, geometry.Vector3(1, 2, 3))

    object:resize(0, -1, -2)
    assertEqual(object.transform.size, geometry.Vector3(1, 1, 1))
    assertEqual(object.globalSize, geometry.Vector3(1, 1, 1))


    --[[resizing with a child]]
    local child = self:createEntity(scene, "test child", nil, object)

    assertEqual(child.transform.size, geometry.Vector3(1, 1, 1))
    assertEqual(child.globalSize, geometry.Vector3(1, 1, 1))

    object:resize(1, 1, 1)
    assertEqual(child.transform.size, geometry.Vector3(1, 1, 1))
    assertEqual(child.globalSize, geometry.Vector3(2, 2, 2))

    child:resize(2, 2, 2)
    assertEqual(child.transform.size, geometry.Vector3(3, 3, 3))
    assertEqual(child.globalSize, geometry.Vector3(6, 6, 6))

    child:resize(1, 2, 3)
    assertEqual(child.transform.size, geometry.Vector3(4, 5, 6))
    assertEqual(child.globalSize, geometry.Vector3(8, 10, 12))

    object:resize(-1, -1, -1)
    assertEqual(child.transform.size, geometry.Vector3(4, 5, 6))
    assertEqual(child.globalSize, geometry.Vector3(4, 5, 6))

    child:resize(-3, -4, -5)
    assertEqual(child.transform.size, geometry.Vector3(1, 1, 1))
    assertEqual(child.globalSize, geometry.Vector3(1, 1, 1))


    --[[testing that allowNegativeSize was removed]]
    local success = pcall(function() object:resize(-100, -100, -100, false) end)
    assertEqual(success, false)

    -- test on child this time, since `object` was made useless by the above test
    success = pcall(function() child:resize(-100, -100, -100, true) end)
    assertEqual(success, false)

end

function GameEntityTest:testRotate(scene)

    --[[setup]]
    local object = self:createEntity(scene, "test")

    assertEqual(object.transform.rotation, 0)
    assertEqual(object.globalRotation, 0)

    object:rotate(45)
    assertEqual(object.transform.rotation, 45)
    assertEqual(object.globalRotation, 45)

    object:rotate(45)
    assertEqual(object.transform.rotation, 90)
    assertEqual(object.globalRotation, 90)

    object:rotate(-40)
    assertEqual(object.transform.rotation, 50)
    assertEqual(object.globalRotation, 50)

    object:rotate(360)
    assertEqual(object.transform.rotation, 50)
    assertEqual(object.globalRotation, 50)

    object:rotate(-360)
    assertEqual(object.transform.rotation, 50)
    assertEqual(object.globalRotation, 50)
end

function GameEntityTest:testRotateTo(scene)

    local object = self:createEntity(scene, "test")

    object:rotateTo(0)
    assertEqual(object.transform.rotation, 0)
    assertEqual(object.globalRotation, 0)

    object:rotateTo(78)
    assertEqual(object.transform.rotation, 78)
    assertEqual(object.globalRotation, 78)

    object:rotateTo(192)
    assertEqual(object.transform.rotation, 192)
    assertEqual(object.globalRotation, 192)

    object:rotateTo(360)
    assertEqual(object.transform.rotation, 0)
    assertEqual(object.globalRotation, 0)

    object:rotateTo(-361)
    assertEqual(object.transform.rotation, 359)
    assertEqual(object.globalRotation, 359)

end

function GameEntityTest:testChildRotate(scene)

    --[[setup]]
    local object = self:createEntity(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)

    assertEqual(child.transform.rotation, 0)
    assertEqual(child.globalRotation, 0)

    object:rotate(45)
    assertEqual(child.transform.rotation, 0)
    assertEqual(child.globalRotation, 45)

    child:rotate(45)
    assertEqual(child.transform.rotation, 45)
    assertEqual(child.globalRotation, 90)

    object:rotate(-40)
    assertEqual(child.transform.rotation, 45)
    assertEqual(child.globalRotation, 50)

    child:rotate(-20)
    assertEqual(child.transform.rotation, 25)
    assertEqual(child.globalRotation, 30)

    object:rotate(360)
    child:rotate(-360)
    assertEqual(child.transform.rotation, 25)
    assertEqual(child.globalRotation, 30)
end

function GameEntityTest.testChildRotateTo(self,scene)

    local object = self:createEntity(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)

    object:rotateTo(0)
    child:rotateTo(0)
    assertEqual(child.transform.rotation, 0)
    assertEqual(child.globalRotation, 0)

    object:rotateTo(70)
    assertEqual(child.transform.rotation, 0)
    assertEqual(child.globalRotation, 70)

    child:rotateTo(80)
    assertEqual(child.transform.rotation, 80)
    assertEqual(child.globalRotation, 150)

    object:rotateTo(360)
    child:rotateTo(-361)
    assertEqual(child.transform.rotation, 359)
    assertEqual(child.globalRotation, 359)
end

function GameEntityTest:testRemoveChild(scene)

    local object = self:createEntity(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)
    local grandchild = self:createEntity(scene, "test child", nil, child)

    object:removeChild(child)
    assertEqual(helpers.searchTreeDepth(object.children, object), nil)
    assertEqual(helpers.searchTreeDepth(object.children, grandchild), nil)

    object:addChild(child)
    object:removeChild(child, false) --don't remove grandchild
    assertEqual(helpers.searchTreeDepth(object.children, object), nil)
    assertEqual(helpers.searchTreeDepth(object.children, grandchild), 1)

    object:removeChild(self:createEntity(scene, "anonymous"))
    assertEqual(helpers.searchTreeDepth(object.children, grandchild), 1)

    --edge case, testing removing an object from itself
    child = self:createEntity(scene, "test child", nil, object)
    child:removeChild(child)
    assertEqual(helpers.searchTreeDepth(object.children, child), 1)
end


return GameEntityTest
