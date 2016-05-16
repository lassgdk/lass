local lass = require("lass")
local turtlemode = require("turtlemode")
local helpers = require("tests.coretest.helpers")
local GameEntityTest = require("tests.coretest.gameentitytest")
local assertLen, assertEqual = turtlemode.assertLen, turtlemode.assertEqual

local GameSceneTest = turtlemode.testModule(GameEntityTest)

function GameSceneTest:createEntity(scene, name, transform, parent)
    return lass.GameScene(transform, nil, parent)
end

function GameSceneTest.fixtures.scene(self)
    return lass.GameScene()
end

function GameSceneTest:testRemoveChild(scene)

    GameEntityTest.testRemoveChild(self, scene)

    local object = lass.GameObject(scene, "testing object")
    local child = lass.GameObject(scene, "test child", nil, object)

    scene:removeChild(object)
    assertEqual(object.active, true, "object was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)

    object = lass.GameObject(scene, "testing object")
    child = lass.GameObject(scene, "test child", nil, object)

    scene:removeChild(object, true)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
    assertEqual(helpers.searchTreeDepth(object.children, child), 1, "child was incorrectly removed from object")

    object = lass.GameObject(scene, "test")
    child = lass.GameObject(scene, "test child", nil, object)

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
end

function GameSceneTest:testGameObjects(scene)

    assertLen(scene.gameObjects, 0)

    local object = lass.GameObject(scene, "test")
    assertLen(scene.gameObjects, 1)

    local child = lass.GameObject(scene, "test child", nil, object)
    assertLen(scene.gameObjects, 2)

    local grandchild = lass.GameObject(scene, "test grandchild", child)
    assertLen(scene.gameObjects, 3)

    local object2 = lass.GameObject(scene, "test 2")
    assertLen(scene.gameObjects, 4)
end

function GameSceneTest.fail.testRemoveGameObject(self, scene)

    local object = lass.GameObject(scene, "test")
    local child = lass.GameObject(scene, "test child", nil, object)

    -- test removing object and child

    scene:removeGameObject(object, true)
    assertEqual(object.active, false, "object was not deactivated")
    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")
    assertEqual(helpers.searchTreeDepth(object.children, child), 1, "child was removed from object")

    -- a second call should produce no error
    scene:removeGameObject(object)

    -- test removing object without removing child

    object = lass.GameObject(scene, "test")
    child = lass.GameObject(scene, "test child", nil, object)

    scene:removeGameObject(object, false)
    assertEqual(object.active, false, "object was not deactivated")
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)
    assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
    assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")

    --currently failing:
    assertEqual(helpers.searchTreeDepth(object.children, child), nil, "child was not removed from object")

    scene:removeGameObject(child)
    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), nil, "child was not removed from scene")

end

return GameSceneTest