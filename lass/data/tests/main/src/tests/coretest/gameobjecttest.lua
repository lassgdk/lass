local lass = require("lass")
local geometry = require("lass.geometry")
local turtlemode = require("turtlemode")
local helpers = require("tests.coretest.helpers")

local GameObjectTest = turtlemode.testModule("tests.coretest.gameentitytest")
local assertEqual = turtlemode.assertEqual

function GameObjectTest.fixtures.scene(self)
	return lass.GameScene()
end

function GameObjectTest:createEntity(scene, name, transform, parent)
    return lass.GameObject(scene, name, transform, parent)
end

function GameObjectTest:testGameObjectMoveToGlobal(scene)

    --[[setup]]
    local object = lass.GameObject(scene, "test")
    local child = lass.GameObject(scene, "test child")
    object:addChild(child)


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

function GameObjectTest:testGameObjectResizing(scene)

    --[[setup]]
    local object = lass.GameObject(scene, "test")

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


    --[[testing useNegative]]
    object:resize(-100, -100, -100, false)
    assertEqual(object.transform.size, geometry.Vector3(0, 0, 0))
    assertEqual(object.globalSize, geometry.Vector3(0, 0, 0))

    object:resize(-2, -4, -7, true)
    assertEqual(object.transform.size, geometry.Vector3(-2, -4, -7))
    assertEqual(object.globalSize, geometry.Vector3(-2, -4, -7))

    object:resize(-2, -4, -7, false)
    assertEqual(object.transform.size, geometry.Vector3(0, 0, 0))
    assertEqual(object.globalSize, geometry.Vector3(0, 0, 0))

    object:resize(-2, -4, -7, true)
    object:resize(-2, -4, -7, true)
    assertEqual(object.transform.size, geometry.Vector3(-4, -8, -14))
    assertEqual(object.globalSize, geometry.Vector3(-4, -8, -14))

end

function GameObjectTest:testGameObjectChildResizing(scene)

    --[[setup]]
    local object = lass.GameObject(scene, "test")
    local child = lass.GameObject(scene, "test child")
    object:addChild(child)

    assertEqual(child.transform.size, geometry.Vector3(1, 1, 1))
    assertEqual(child.globalSize, geometry.Vector3(1, 1, 1))


    --[[GameEntity.resize]]
    object:resize(1, 1, 1)
    assertEqual(child.transform.size, geometry.Vector3(1, 1, 1))
    assertEqual(child.globalSize, geometry.Vector3(2, 2, 2))

    child:resize(2, 2, 2)
    assertEqual(child.transform.size, geometry.Vector3(3, 3, 3))
    assertEqual(child.globalSize, geometry.Vector3(6, 6, 6))

    child:resize(1, 2, 3)
    assertEqual(child.transform.size, geometry.Vector3(4, 5, 6))
    assertEqual(child.globalSize, geometry.Vector3(8, 10, 12))


    --[[testing useNegative]]
    object:resize(-100, -100, -100, false)
    assertEqual(child.transform.size, geometry.Vector3(4, 5, 6))
    assertEqual(child.globalSize, geometry.Vector3(0, 0, 0))

    child:resize(-100, -100, -100, false)
    assertEqual(child.transform.size, geometry.Vector3(0, 0, 0))
    assertEqual(child.globalSize, geometry.Vector3(0, 0, 0))

    object:resize(-1, -2, -3, true)
    assertEqual(child.transform.size, geometry.Vector3(0, 0, 0))
    assertEqual(child.globalSize, geometry.Vector3(0, 0, 0))

    child:resize(1, 1, 1, false)
    assertEqual(child.transform.size, geometry.Vector3(1, 1, 1))
    assertEqual(child.globalSize, geometry.Vector3(-1, -2, -3))

    child:resize(-3, -3, -3, true)
    assertEqual(child.transform.size, geometry.Vector3(-2, -2, -2))
    assertEqual(child.globalSize, geometry.Vector3(2, 4, 6))

    child:resize(-2, -2, -2, false)
    assertEqual(child.transform.size, geometry.Vector3(0, 0, 0))
    assertEqual(child.globalSize, geometry.Vector3(0, 0, 0))

    child:resize(-2, -2, -2, true)
    child:resize(-2, -2, -2, true)
    assertEqual(child.transform.size, geometry.Vector3(-4, -4, -4))
    assertEqual(child.globalSize, geometry.Vector3(4, 8, 12))


end

function GameObjectTest:testGameObjectRotation(scene)

    --[[setup]]
    local object = lass.GameObject(scene, "test")

    assertEqual(object.transform.rotation, 0)
    assertEqual(object.globalRotation, 0)


    --[[GameObject.rotate]]
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


    --[[GameObject.rotate]]
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

function GameObjectTest:testGameObjectChildRotation(scene)

    --[[setup]]
    local object = lass.GameObject(scene, "test")
    local child = lass.GameObject(scene, "test child")
    object:addChild(child)

    assertEqual(child.transform.rotation, 0)
    assertEqual(child.globalRotation, 0)


    --[[GameObject.rotate]]
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


    --[[GameObject.rotate]]
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

function GameObjectTest:testGameObjectRemovalWithoutChildren(scene)

    --[[GameScene:removeGameObject]]
    local object = lass.GameObject(scene, "testing object")

    scene:removeGameObject(object)
    assertEqual(object.active, false, "object was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)

    -- a second call should produce no error
    scene:removeGameObject(object)


    --[[GameObject:destroy]]
    object = lass.GameObject(scene, "testing object")

    object:destroy()
    assertEqual(object.active, false, "object was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)

    -- a second call should produce no error
    object:destroy()


    --[[GameScene:removeChild]]
    object = lass.GameObject(scene, "testing object")

    scene:removeChild(object)
    assertEqual(object.active, true, "object was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)


    --[[GameObject:removeChild]]
    object = lass.GameObject(scene, "testing object")

    object:removeChild(object)
    assertEqual(object.active, true, "object was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), 1)

end

function GameObjectTest:testGameObjectRemovalWithChildren(scene)

    --[[GameScene:removeGameObject]]
    local object = lass.GameObject(scene, "test")
    local child = lass.GameObject(scene, "test child")
    object:addChild(child)

    scene:removeGameObject(object, true)
    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
    -- assertEqual(helpers.searchTreeDepth(object.children, child), nil, "child was not removed from object")

    object = lass.GameObject(scene, "test")
    child = lass.GameObject(scene, "test child")
    object:addChild(child)

    scene:removeGameObject(object, false)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
    assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")

    scene:removeGameObject(child)
    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
    -- assertEqual(helpers.searchTreeDepth(object.children, child), nil, "child was not removed from object")


    --[[GameObject:destroy]]
    object = lass.GameObject(scene, "test")
    child = lass.GameObject(scene, "test child")
    object:addChild(child)

    object:destroy(true)
    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")

    object = lass.GameObject(scene, "test")
    child = lass.GameObject(scene, "test child")
    object:addChild(child)

    object:destroy(false)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
    assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")

    -- this shouldn't do anything, since the object was already destroyed
    object:destroy(true)
    assertEqual(child.active, true, "child was incorrectly deactivated")

    child:destroy()
    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")

    -- a second call should produce no error
    child:destroy()


    --[[GameScene:removeChild]]
    object = lass.GameObject(scene, "test")
    child = lass.GameObject(scene, "test child")
    object:addChild(child)

    scene:removeChild(object, true)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
    assertEqual(helpers.searchTreeDepth(object.children, child), 1, "child was incorrectly removed from object")

    object = lass.GameObject(scene, "test")
    child = lass.GameObject(scene, "test child")
    object:addChild(child)

    scene:removeChild(child)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), 2,
        "child was removed from scene children, even though it's not a direct child")
    assertEqual(helpers.searchTreeDepth(object.children, child), 1, "child was incorrectly removed from object")

    scene:removeChild(object, false)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
    assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")
    assertEqual(helpers.searchTreeDepth(object.children, child), 1, "child was incorrectly removed from object")

    scene:removeChild(child)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")


    --[[GameObject:removeChild]]
    object = lass.GameObject(scene, "test")
    child = lass.GameObject(scene, "test child")
    object:addChild(child)

    child:removeChild(child)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), 2, "child was incorrectly removed from scene children")

    object:removeChild(child)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
    assertEqual(helpers.searchTreeDepth(object.children, child), nil, "child was not removed from object")

end

return GameObjectTest