local m = {}

function m.searchTreeDepth(list, value, depth)

    if depth == nil then
        depth = 1
    end

    for i, entity in ipairs(list) do

        if entity == value then
            return depth
        else
            local found = m.searchTreeDepth(entity.children, value, depth+1)
            if found then
                return found
            end
        end
    end
end

function m.searchTreeCount(list, value, count)

    if count == nil then
        count = 0
    end

    for i, entity in ipairs(list) do

        if entity == value then
            count = count + 1
        end
        count = m.searchTreeCount(entity.children, value, count)

    end

    return count
end

function m.numTreeNodes(entity)

    local count = 0

    for i, child in ipairs(entity.children) do
        count = count + 1 + m.numTreeNodes(child)
    end

    return count
end

local function objectRemoval(scene, functionType, gameObject, destroyDescendants)

    if functionType == "object" then
        gameObject:destroy(destroyDescendants)
    elseif functionType == "scene" then
        scene:removeGameObject(gameObject, destroyDescendants)
    else
        error("incorrect functionType value")
    end

end

function m.objectRemovalTestRunner(scene, functionType)
    -- functionType is either "object" or "scene", referring to
    -- GameObject:destroy or GameScene:removeGameObject, respectively

    --[[normal usage]]
    local object = self:createEntity(scene, "testing object")

    objectRemoval(scene, functionType, object)
    assertFalse(object.active, "object was not deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), nil)

    -- a second call should produce no error
    objectRemoval(scene, functionType, object)
    assertFalse(object.active, "object was reactivated")


    --[[test destroying all children of object]]
    object = lass.GameObject(scene, "test")
    local child = self:createEntity(scene, "test child", nil, object)
    local child2 = self:createEntity(scene, "test child2", nil, object)
    local grandchild = self:createEntity(scene, "test grandchild", nil, child)

    objectRemoval(scene, functionType, object, true)

    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeCount(scene.children, child), 0, "child was not removed from scene")

    assertEqual(child2.active, false, "child2 was not deactivated")
    assertEqual(helpers.searchTreeCount(scene.children, child2), 0, "child2 was not removed from scene")

    assertEqual(grandchild.active, false, "grandchild was not deactivated")
    assertEqual(
        helpers.searchTreeDepth(scene.children, grandchild), nil, "grandchild was not removed from scene")


    --[[destroy object without removing any children]]
    object = self:createEntity(scene, "test")
    child = self:createEntity(scene, "test child", nil, object)

    objectRemoval(scene, functionType, object, false)
    assertEqual(child.active, true, "child was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, child), 1, "child was not made a child of the scene")
    assertEqual(helpers.searchTreeCount(scene.children, child), 1, "child reference count is incorrect")

    -- this shouldn't do anything, since the object was already destroyed
    objectRemoval(scene, functionType, object, true)
    assertEqual(child.active, true, "child was incorrectly deactivated")

    -- try destroying the child in isolation
    objectRemoval(scene, functionType, child)
    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeCount(scene.children, child), 0, "child was not removed from scene")

    -- a second call should produce no error
    child:destroy()
    objectRemoval(scene, functionType, child)
    assertFalse(child.active, "child was reactivated somehow")


    --[[destroy child object without destroying descendants]]
    object = lass.GameObject(scene, "test")
    child = self:createEntity(scene, "test child", nil, object)
    grandchild = self:createEntity(scene, "test grandchild", nil, child)

    objectRemoval(scene, functionType, child, false)

    assertEqual(object.active, true, "object was incorrectly deactivated")
    assertEqual(helpers.searchTreeDepth(scene.children, object), 1, "object was not left a child of the scene")
    assertEqual(helpers.searchTreeCount(scene.children, object), 1, "object reference count is incorrect")

    assertEqual(child.active, false, "child was not deactivated")
    assertEqual(helpers.searchTreeCount(scene.children, child), 0, "child was not removed from scene")

    assertEqual(grandchild.active, true, "grandchild was incorrectly deactivated")
    assertEqual(
        helpers.searchTreeDepth(scene.children, grandchild), 1,
        "grandchild was not made a child of the scene")
    assertEqual(
        helpers.searchTreeCount(scene.children, grandchild), 1,
        "grandchild reference count is incorrect")


end

return m