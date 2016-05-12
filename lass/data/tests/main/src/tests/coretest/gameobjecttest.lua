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

function GameObjectTest:testDestroy(scene)

    --[[GameObject:destroy]]
    object = self:createEntity(scene, "testing object")

    object:destroy()
    assertEqual(object.active, false, "object was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)

    -- a second call should produce no error
    object:destroy()
end

-- function GameObjectTest:testGameObjectRemovalWithoutChildren(scene)

--     --[[GameScene:removeGameObject]]
--     local object = lass.GameObject(scene, "testing object")

--     scene:removeGameObject(object)
--     assertEqual(object.active, false, "object was not deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, object), nil)

--     -- a second call should produce no error
--     scene:removeGameObject(object)


--     --[[GameObject:destroy]]
--     object = lass.GameObject(scene, "testing object")

--     object:destroy()
--     assertEqual(object.active, false, "object was not deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, object), nil)

--     -- a second call should produce no error
--     object:destroy()


--     --[[GameScene:removeChild]]
--     object = lass.GameObject(scene, "testing object")

--     scene:removeChild(object)
--     assertEqual(object.active, true, "object was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, object), nil)


--     --[[GameObject:removeChild]]
--     object = lass.GameObject(scene, "testing object")

--     object:removeChild(object)
--     assertEqual(object.active, true, "object was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, object), 1)

-- end

-- function GameObjectTest:testGameObjectRemovalWithChildren(scene)

--     --[[GameScene:removeGameObject]]
--     local object = lass.GameObject(scene, "test")
--     local child = lass.GameObject(scene, "test child")
--     object:addChild(child)

--     scene:removeGameObject(object, true)
--     assertEqual(child.active, false, "child was not deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
--     -- assertEqual(helpers.searchTreeDepth(object.children, child), nil, "child was not removed from object")

--     object = lass.GameObject(scene, "test")
--     child = lass.GameObject(scene, "test child")
--     object:addChild(child)

--     scene:removeGameObject(object, false)
--     assertEqual(child.active, true, "child was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
--     assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")

--     scene:removeGameObject(child)
--     assertEqual(child.active, false, "child was not deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
--     -- assertEqual(helpers.searchTreeDepth(object.children, child), nil, "child was not removed from object")


--     --[[GameObject:destroy]]
--     object = lass.GameObject(scene, "test")
--     child = lass.GameObject(scene, "test child")
--     object:addChild(child)

--     object:destroy(true)
--     assertEqual(child.active, false, "child was not deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")

--     object = lass.GameObject(scene, "test")
--     child = lass.GameObject(scene, "test child")
--     object:addChild(child)

--     object:destroy(false)
--     assertEqual(child.active, true, "child was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
--     assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")

--     -- this shouldn't do anything, since the object was already destroyed
--     object:destroy(true)
--     assertEqual(child.active, true, "child was incorrectly deactivated")

--     child:destroy()
--     assertEqual(child.active, false, "child was not deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")

--     -- a second call should produce no error
--     child:destroy()


--     --[[GameScene:removeChild]]
--     object = lass.GameObject(scene, "test")
--     child = lass.GameObject(scene, "test child")
--     object:addChild(child)

--     scene:removeChild(object, true)
--     assertEqual(child.active, true, "child was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
--     assertEqual(helpers.searchTreeDepth(object.children, child), 1, "child was incorrectly removed from object")

--     object = lass.GameObject(scene, "test")
--     child = lass.GameObject(scene, "test child")
--     object:addChild(child)

--     scene:removeChild(child)
--     assertEqual(child.active, true, "child was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), 2,
--         "child was removed from scene children, even though it's not a direct child")
--     assertEqual(helpers.searchTreeDepth(object.children, child), 1, "child was incorrectly removed from object")

--     scene:removeChild(object, false)
--     assertEqual(child.active, true, "child was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
--     assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")
--     assertEqual(helpers.searchTreeDepth(object.children, child), 1, "child was incorrectly removed from object")

--     scene:removeChild(child)
--     assertEqual(child.active, true, "child was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")


--     --[[GameObject:removeChild]]
--     object = lass.GameObject(scene, "test")
--     child = lass.GameObject(scene, "test child")
--     object:addChild(child)

--     child:removeChild(child)
--     assertEqual(child.active, true, "child was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), 2, "child was incorrectly removed from scene children")

--     object:removeChild(child)
--     assertEqual(child.active, true, "child was incorrectly deactivated")
--     assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
--     assertEqual(helpers.searchTreeDepth(object.children, child), nil, "child was not removed from object")

-- end

return GameObjectTest