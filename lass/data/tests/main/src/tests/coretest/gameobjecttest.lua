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


function GameObjectTest:createEntity(scene, name, transform, parent)
    return lass.GameObject(scene, name, transform, parent)
end

function GameObjectTest.fixtures.scene(self)
    return lass.GameScene()
end

function GameObjectTest.testDestroy(self, scene)

    self:objectRemovalTestRunner(scene, "object")
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
        helpers.searchTreeDepth(scene.children, child), 2, "child was incorrectly removed from scene children")

    object:removeChild(child)
    assertEqual(child.active, true, "child was incorrectly deactivated")
end

return GameObjectTest