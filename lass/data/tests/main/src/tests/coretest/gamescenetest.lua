local lass = require("lass")
local turtlemode = require("turtlemode")
local assertLen = turtlemode.assertLen

local m = turtlemode.testModule()

function m.testChildrenAndGameObjects(scene)

    assertLen(scene.gameObjects, 0)

    local object = lass.GameObject(scene, "test")
    assertLen(scene.gameObjects, 1)

    local child = lass.GameObject(scene, "test child")
end

return m