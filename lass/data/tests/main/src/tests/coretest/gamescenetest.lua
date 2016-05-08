local lass = require("lass")
local turtlemode = require("turtlemode")
local helpers = require("tests.coretest.helpers")
local assertLen, assertEqual = turtlemode.assertLen, turtlemode.assertEqual

local m = turtlemode.testModule()

function m.testChildrenAndGameObjects(scene)

    assertLen(scene.gameObjects, 0)

    local object = lass.GameObject(scene, "test")
    assertLen(scene.gameObjects, 1)
    assertEqual(helpers.numTreeNodes(scene), 1)

    local child = lass.GameObject(scene, "test child")
    assertLen(scene.gameObjects, 2)
    assertEqual(helpers.numTreeNodes(scene), 2)
end

return m