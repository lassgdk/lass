local lass = require("lass")
local geometry = require("lass.geometry")
local turtlemode = require("turtlemode")
local helpers = require("tests.coretest.helpers")
local GameEntityTest = require("tests.coretest.gameentitytest")

local GameObjectTest = turtlemode.testModule(GameEntityTest)
local assertEqual, assertFalse, assertTrue =
    turtlemode.assertEqual,
    turtlemode.assertFalse,
    turtlemode.assertTrue

function GameObjectTest.fixtures.scene(self)
    return lass.GameScene()
end

function GameObjectTest:createEntity(scene, name, transform, parent)
    return lass.GameObject(scene, name, transform, parent)
end

function GameObjectTest.fail.testDestroy(self, scene)

    --[[normal usage]]
    local object = self:createEntity(scene, "testing object")

    object:destroy()
    assertFalse(object.active, "object was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)

    -- a second call should produce no error
    object:destroy()
    assertFalse(object.active, "object was reactivated")


    --[[test destroying all children of object]]
    object = lass.GameObject(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)
    local child2 = self:createEntity(scene, "test child2", nil, object)
    local grandchild = self:createEntity(scene, "test grandchild", nil, child)

    object:destroy(true)

    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeCount(scene.children, child), 0, "child was not removed from scene")

    assertEqual(child2.active, false, "child2 was not deactivated")
    assertEqual(helpers.searchTreeCount(scene.children, child2), 0, "child2 was not removed from scene")

    assertEqual(grandchild.active, false, "grandchild was not deactivated")
    assertEqual(
        helpers.searchTreeDepth(scene.children, grandchild),
        nil,
        "grandchild was not removed from scene"
    )


    --[[destroy object without removing any children]]
    object = self:createEntity(scene, "test")
    child = self:createEntity(scene, "test child", nil, object)

    object:destroy(false)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
    assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")

    -- this shouldn't do anything, since the object was already destroyed
    object:destroy(true)
    assertEqual(child.active, true, "child was incorrectly deactivated")

    -- try destroying the child in isolation
    child:destroy()
    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeCount(scene.children, child), 0, "child was not removed from scene")

    -- a second call should produce no error
    child:destroy()
    assertFalse(child.active, "child was reactivated somehow")


    --[[destroy child object without destroying descendants]]
    object = lass.GameObject(scene, "test")
    child = self:createEntity(scene, "test child", nil, object)
    grandchild = self:createEntity(scene, "test grandchild", nil, child)

    child:destroy(false)

    assertEqual(object.active, true, "object was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), 1, "object was not left a child of the scene")
    assertEqual(helpers.searchTreeCount(scene.children, object), 1, "object reference count is incorrect")

    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeCount(scene.children, child), 0, "child was not removed from scene")

    assertEqual(grandchild.active, true, "grandchild was incorrectly deactivated")
    assertEqual(
        helpers.searchTreeDepth(scene.children, grandchild),
        1,
        "grandchild was not made a child of the scene"
    )
    assertEqual(
        helpers.searchTreeCount(scene.children, grandchild),
        1,
        "grandchild reference count is incorrect"
    )

end

function GameObjectTest:testRemoveChild(scene)

    GameEntityTest.testRemoveChild(self, scene)

    local object = self:createEntity(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)

    object:removeChild(child)
    assertTrue(child.active, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(object.children, child), nil, "child was not removed from object")
    assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was removed from scene")

    -- edge case: test removing object from itself
    object:removeChild(object)
    assertTrue(object.active, "object was incorrectly deactivated")

    child = self:createEntity(scene, "test child", nil, object)

    child:removeChild(child)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(
        helpers.searchTreeDepth(scene.children, child),
        2,
        "child was incorrectly removed from scene children"
    )

    object:removeChild(child)
    assertEqual(child.active, true, "child was incorrectly deactivated")
end

return GameObjectTest