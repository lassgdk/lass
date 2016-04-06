local lass = require("lass")
local geometry = require("lass.geometry")
local turtlemode = require("turtlemode")

local coretest = {}


local function testLocalPosition(object, assertedPosition)

	turtlemode.assertEqual(
		object.transform.position, assertedPosition, "local transform position"
	)
end

local function testGlobalPosition(object, assertedPosition)

	turtlemode.assertEqual(
		object.globalTransform.position, assertedPosition, "global transform position"
	)
end

local function testLocalSize(object, assertedSize)

	local s1, s2 = tostring(assertedSize), tostring(object.transform.size)
	assert(
		object.transform.size == assertedSize,
		"local transform size should be" .. s1 .. " but is " .. s2
	)

end

local function testGlobalSize(object, assertedSize)

	local s1, s2 = tostring(assertedSize), tostring(object.globalSize)
	assert(
		object.globalSize == assertedSize,
		"global transform size should be" .. s1 .. " but is " .. s2
	)

end

local function searchTreeDepth(list, value, depth)

	if depth == nil then
		depth = 1
	end

	for i, entity in ipairs(list) do
		-- debug.log(value.name, entity.name, depth)
		if entity == value then
			return depth
		else
			local found = searchTreeDepth(entity.children, value, depth+1)
			if found then
				return found
			end
		end
	end

end

local function searchTreeCount(list, value, count)

	if count == nil then
		count = 0
	end

	for i, entity in ipairs(list) do
		if entity == value then
			count = count + 1
		end
		-- debug.log(value.name, entity.name, count)
		count = searchTreeCount(entity.children, value, count)
	end

	return count

end

function coretest.testGameObjectMovement(scene)
	--[[setup]]
	local object = lass.GameObject(scene, "test")

	testLocalPosition(object, geometry.Vector3(0, 0, 0))
	testGlobalPosition(object, geometry.Vector3(0, 0, 0))


	--[[GameObject.move]]
	object:move(5, 5)
	object:move(0, 1)
	testLocalPosition(object, geometry.Vector3(5, 6, 0))
	testGlobalPosition(object, geometry.Vector3(5, 6, 0))

	object:move(-5, -6)
	testLocalPosition(object, geometry.Vector3(0, 0, 0))
	testGlobalPosition(object, geometry.Vector3(0, 0, 0))


	--[[GameObject.moveTo]]
	object:moveTo(-2, 10)
	testLocalPosition(object, geometry.Vector3(-2, 10, 0))
	testGlobalPosition(object, geometry.Vector3(-2, 10, 0))

	object:moveTo(0, 0)
	testLocalPosition(object, geometry.Vector3(0, 0, 0))
	testGlobalPosition(object, geometry.Vector3(0, 0, 0))


	--[[GameObject.moveGlobal]]
	object:moveGlobal(5, 5)
	object:moveGlobal(0, 1)
	testLocalPosition(object, geometry.Vector3(5, 6, 0))
	testGlobalPosition(object, geometry.Vector3(5, 6, 0))

	object:moveGlobal(-5, -6)
	testLocalPosition(object, geometry.Vector3(0, 0, 0))
	testGlobalPosition(object, geometry.Vector3(0, 0, 0))


	--[[GameObject.moveToGlobal]]
	object:moveToGlobal(-2, 10)
	testLocalPosition(object, geometry.Vector3(-2, 10, 0))
	testGlobalPosition(object, geometry.Vector3(-2, 10, 0))

	object:moveToGlobal(0, 0)
	testLocalPosition(object, geometry.Vector3(0, 0, 0))
	testGlobalPosition(object, geometry.Vector3(0, 0, 0))

end

function coretest.testGameObjectChildMovement(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	testLocalPosition(object, geometry.Vector3(0, 0, 0))
	testGlobalPosition(object, geometry.Vector3(0, 0, 0))


	--[[GameObject.move]]
	object:move(5, 5)
	child:move(0, 1)
	testLocalPosition(child, geometry.Vector3(0, 1,0))
	testGlobalPosition(child, geometry.Vector3(5, 6, 0))

	object:move(-5, -5)
	child:move(0, -1)
	testLocalPosition(child, geometry.Vector3(0, 0, 0))
	testGlobalPosition(child, geometry.Vector3(0, 0, 0))


	--[[GameObject.moveTo]]
	object:moveTo(10, 10)
	child:moveTo(-2, 0)
	testLocalPosition(child, geometry.Vector3(-2, 0, 0))
	testGlobalPosition(child, geometry.Vector3(8, 10, 0))

	object:moveTo(0, 0)
	testLocalPosition(child, geometry.Vector3(-2, 0, 0))
	testGlobalPosition(child, geometry.Vector3(-2, 0, 0))

	child:moveTo(0, 0)
	testLocalPosition(child, geometry.Vector3(0, 0, 0))
	testGlobalPosition(child, geometry.Vector3(0, 0, 0))


	--[[GameObject.moveGlobal]]
	object:moveGlobal(5, 5)
	child:moveGlobal(0, 1)
	testLocalPosition(child, geometry.Vector3(0, 1,0))
	testGlobalPosition(child, geometry.Vector3(5, 6, 0))

	object:moveGlobal(-5, -5)
	testLocalPosition(child, geometry.Vector3(0, 1,0))
	testGlobalPosition(child, geometry.Vector3(0, 1,0))

	child:moveGlobal(0, -1)
	testLocalPosition(child, geometry.Vector3(0, 0, 0))
	testGlobalPosition(child, geometry.Vector3(0, 0, 0))


	--[[GameObject.moveToGlobal]]
	object:moveToGlobal(-2, 10)
	child:moveToGlobal(5, 5)
	testLocalPosition(child, geometry.Vector3(7, -5, 0))
	testGlobalPosition(child, geometry.Vector3(5, 5, 0))

	object:moveToGlobal(0, 0)
	testLocalPosition(child, geometry.Vector3(7, -5, 0))
	testGlobalPosition(child, geometry.Vector3(7, -5, 0))

	child:moveToGlobal(0, 0)
	testLocalPosition(child, geometry.Vector3(0, 0, 0))
	testGlobalPosition(child, geometry.Vector3(0, 0, 0))

end

function coretest.testGameObjectChildGlobalMovement(scene)

	-- tests on global movement of a child accounting for the parent's global size/rotation

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)


	--[[accounting for global size]]
	child:moveTo(2, 2, 2)
	object:resize(1, 1, 1)
	testLocalPosition(child, geometry.Vector3(2, 2, 2))
	testGlobalPosition(child, geometry.Vector3(4, 4, 4))

	-- these fail and require changes to GameEntity:moveGlobal
	-- child:moveGlobal(-2, -2, -2)
	-- testLocalPosition(child, geometry.Vector3(1, 1, 1))
	-- testGlobalPosition(child, geometry.Vector3(2, 0, 0))

	-- these fail and require changes to GameEntity:moveToGlobal
	-- child:moveToGlobal(8, 8, 8)
	-- testLocalPosition(child, geometry.Vector3(4, 4, 4))
	-- testGlobalPosition(child, geometry.Vector3(8, 8, 8))

	child:moveTo(2, 2, 2)
	object:resize(-1.5, -1.5, -1.5)
	testLocalPosition(child, geometry.Vector3(2, 2, 2))
	testGlobalPosition(child, geometry.Vector3(1, 1, 1))


	--[[accounting for global rotation]]
	-- reset object size
	object:resize(.5, .5, .5)
	
	-- z value doesn't get rotated, so it's set to 0 here
	child:moveTo(2, 4, 0)
	object:rotateTo(180)
	testLocalPosition(child, geometry.Vector3(2, 4, 0))
	testGlobalPosition(child, geometry.Vector3(-2, -4, 0))

	child:moveGlobal(-2, -4)
	testLocalPosition(child, geometry.Vector3(4, 8, 0))
	testGlobalPosition(child, geometry.Vector3(-4,-8,0))

	-- these fail and require changes to GameEntity:moveToGlobal
	-- child:moveToGlobal(-8, -16)
	-- testLocalPosition(child, geometry.Vector3(8, 16, 0))
	-- testGlobalPosition(child, geometry.Vector3(-8, -16, 0))

	child:moveTo(2, 4)
	object:rotateTo(90)
	testLocalPosition(child, geometry.Vector3(2, 4, 0))
	testGlobalPosition(child, geometry.Vector3(4, -2, 0))

	child:moveGlobal(4, -2)
	testLocalPosition(child, geometry.Vector3(4, 8, 0))
	testGlobalPosition(child, geometry.Vector3(8, -4,0))

	-- these fail and require changes to GameEntity:moveToGlobal
	-- child:moveToGlobal(16, -8)
	-- testLocalPosition(child, geometry.Vector3(8, 16, 0))
	-- testGlobalPosition(child, geometry.Vector3(16, -8, 0))

end

function coretest.testGameObjectResizing(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")

	testLocalSize(object, geometry.Vector3(1, 1, 1))
	testGlobalSize(object, geometry.Vector3(1, 1, 1))


	--[[GameEntity.resize]]
	object:resize(1, 1, 1)
	testLocalSize(object, geometry.Vector3(2, 2, 2))
	testGlobalSize(object, geometry.Vector3(2, 2, 2))

	object:resize(5, 5, 5)
	testLocalSize(object, geometry.Vector3(7, 7, 7))
	testGlobalSize(object, geometry.Vector3(7, 7, 7))

	object:resize(2, 4, 7)
	testLocalSize(object, geometry.Vector3(9, 11, 14))
	testGlobalSize(object, geometry.Vector3(9, 11, 14))


	--[[testing useNegative]]
	object:resize(-100, -100, -100, false)
	testLocalSize(object, geometry.Vector3(0, 0, 0))
	testGlobalSize(object, geometry.Vector3(0, 0, 0))

	object:resize(-2, -4, -7, true)
	testLocalSize(object, geometry.Vector3(-2, -4, -7))
	testGlobalSize(object, geometry.Vector3(-2, -4, -7))

	object:resize(-2, -4, -7, false)
	testLocalSize(object, geometry.Vector3(0, 0, 0))
	testGlobalSize(object, geometry.Vector3(0, 0, 0))

	object:resize(-2, -4, -7, true)
	object:resize(-2, -4, -7, true)
	testLocalSize(object, geometry.Vector3(-4, -8, -14))
	testGlobalSize(object, geometry.Vector3(-4, -8, -14))

end

function coretest.testGameObjectChildResizing(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	testLocalSize(child, geometry.Vector3(1, 1, 1))
	testGlobalSize(child, geometry.Vector3(1, 1, 1))


	--[[GameEntity.resize]]
	object:resize(1, 1, 1)
	testLocalSize(child, geometry.Vector3(1, 1, 1))
	testGlobalSize(child, geometry.Vector3(2, 2, 2))

	child:resize(2, 2, 2)
	testLocalSize(child, geometry.Vector3(3, 3, 3))
	testGlobalSize(child, geometry.Vector3(6, 6, 6))

	child:resize(1, 2, 3)
	testLocalSize(child, geometry.Vector3(4, 5, 6))
	testGlobalSize(child, geometry.Vector3(8, 10, 12))


	--[[testing useNegative]]
	object:resize(-100, -100, -100, false)
	testLocalSize(child, geometry.Vector3(4, 5, 6))
	testGlobalSize(child, geometry.Vector3(0, 0, 0))

	child:resize(-100, -100, -100, false)
	testLocalSize(child, geometry.Vector3(0, 0, 0))
	testGlobalSize(child, geometry.Vector3(0, 0, 0))

	object:resize(-1, -2, -3, true)
	testLocalSize(child, geometry.Vector3(0, 0, 0))
	testGlobalSize(child, geometry.Vector3(0, 0, 0))

	child:resize(1, 1, 1, false)
	testLocalSize(child, geometry.Vector3(1, 1, 1))
	testGlobalSize(child, geometry.Vector3(-1, -2, -3))

	child:resize(-3, -3, -3, true)
	testLocalSize(child, geometry.Vector3(-2, -2, -2))
	testGlobalSize(child, geometry.Vector3(2, 4, 6))

	child:resize(-2, -2, -2, false)
	testLocalSize(child, geometry.Vector3(0, 0, 0))
	testGlobalSize(child, geometry.Vector3(0, 0, 0))

	child:resize(-2, -2, -2, true)
	child:resize(-2, -2, -2, true)
	testLocalSize(child, geometry.Vector3(-4, -4, -4))
	testGlobalSize(child, geometry.Vector3(4, 8, 12))


end

function coretest.testGameObjectRotation(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")

	assert(object.transform.rotation == 0, "default object rotation wasn't 0")
	assert(object.globalRotation == 0, "default object global rotation wasn't 0")


	--[[GameObject.rotate]]
	object:rotate(45)
	assert(object.transform.rotation == 45, "object wasn't correctly rotated to 45")
	assert(object.globalRotation == 45, "object wasn't correctly globally rotated to 45")

	object:rotate(45)
	assert(object.transform.rotation == 90, "object wasn't correctly rotated to 90")
	assert(object.globalRotation == 90, "object wasn't correctly globally rotated to 90")

	object:rotate(-40)
	assert(object.transform.rotation == 50, "object wasn't correctly rotated to 50")
	assert(object.globalRotation == 50, "object wasn't correctly globally rotated to 50")

	object:rotate(360)
	assert(object.transform.rotation == 50, "object didn't maintain rotation")
	assert(object.globalRotation == 50, "object didn't maintain global rotation")

	object:rotate(-360)
	assert(object.transform.rotation == 50, "object didn't maintain rotation")
	assert(object.globalRotation == 50, "object didn't maintain global rotation")


	--[[GameObject.rotate]]
	object:rotateTo(0)
	assert(object.transform.rotation == 0, "object wasn't correctly rotated to 0")
	assert(object.globalRotation == 0, "object wasn't correctly globally rotated to 0")

	object:rotateTo(78)
	assert(object.transform.rotation == 78, "object wasn't correctly rotated to 78")
	assert(object.globalRotation == 78, "object wasn't correctly globally rotated to 78")

	object:rotateTo(192)
	assert(object.transform.rotation == 192, "object wasn't correctly rotated to 192")
	assert(object.globalRotation == 192, "object wasn't correctly globally rotated to 192")

	object:rotateTo(360)
	assert(object.transform.rotation == 0, "object wasn't correctly rotated to 0")
	assert(object.globalRotation == 0, "object wasn't correctly globally rotated to 0")

	object:rotateTo(-361)
	assert(object.transform.rotation == 359, "object wasn't correctly rotated to 359")
	assert(object.globalRotation == 359, "object wasn't correctly globally rotated to 359")

end

function coretest.testGameObjectChildRotation(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	assert(child.transform.rotation == 0, "default child rotation wasn't 0")
	assert(child.globalRotation == 0, "default child global rotation wasn't 0")


	--[[GameObject.rotate]]
	object:rotate(45)
	assert(child.transform.rotation == 0, "child rotation didn't stay at 0")
	assert(child.globalRotation == 45, "child wasn't correctly globally rotated to 45")

	child:rotate(45)
	assert(child.transform.rotation == 45, "child wasn't correctly rotated to 45")
	assert(child.globalRotation == 90, "child wasn't correctly globally rotated to 90")

	object:rotate(-40)
	assert(child.transform.rotation == 45, "child didn't maintain rotation")
	assert(child.globalRotation == 50, "child wasn't correctly globally rotated to 50")

	child:rotate(-20)
	assert(child.transform.rotation == 25, "child didn't maintain rotation")
	assert(child.globalRotation == 30, "child wasn't correctly globally rotated to 30")

	object:rotate(360)
	child:rotate(-360)
	assert(child.transform.rotation == 25, "child didn't maintain rotation")
	assert(child.globalRotation == 30, "child didn't maintain global rotation")


	--[[GameObject.rotate]]
	object:rotateTo(0)
	child:rotateTo(0)
	assert(child.transform.rotation == 0, "child wasn't correctly rotated to 0")
	assert(child.globalRotation == 0, "child wasn't correctly globally rotated to 0")

	object:rotateTo(70)
	assert(child.transform.rotation == 0, "child didn't maintain rotation")
	assert(child.globalRotation == 70, "child wasn't correctly globally rotated to 70")

	child:rotateTo(80)
	assert(child.transform.rotation == 80, "child wasn't correctly rotated to 80")
	assert(child.globalRotation == 150, "child wasn't correctly globally rotated to 150")

	object:rotateTo(360)
	child:rotateTo(-361)
	assert(child.transform.rotation == 359, "child wasn't correctly rotated to 359")
	assert(child.globalRotation == 359, "child wasn't correctly globally rotated to 359")

end

function coretest.testGlobalPosition(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't default correctly")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't default correctly")


	--[[GameObject.move]]
	object:move(5, 5)
	child:move(0, 1)
	assert(object.globalPosition == geometry.Vector3(5, 5, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(5, 6, 0), "child global position didn't move correctly")

	object:move(-5, -5)
	child:move(0, -1)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't move correctly")


	--[[GameObject.moveTo]]
	object:moveTo(10, 10)
	child:moveTo(-2, 0)
	assert(object.globalPosition == geometry.Vector3(10, 10, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(8, 10, 0), "child global position didn't move correctly")

	object:moveTo(0, 0)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(-2, 0, 0), "child global position didn't move correctly")

	child:moveTo(0, 0)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't stay in place")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't move correctly")


	--[[GameObject.moveGlobal]]
	object:moveGlobal(5, 5)
	child:moveGlobal(0, 1)
	assert(object.globalPosition == geometry.Vector3(5, 5, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(5, 6, 0), "child global position didn't move correctly")

	object:moveGlobal(-5, -5)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(0, 1, 0), "child global position didn't move correctly")

	child:moveGlobal(0, -1)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't stay in place")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't move correctly")


	--[[GameObject.moveToGlobal]]
	object:moveToGlobal(-2, 10)
	child:moveToGlobal(5, 5)
	assert(object.globalPosition == geometry.Vector3(-2, 10, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(5, 5, 0), "child global position didn't move correctly")

	object:moveToGlobal(0, 0)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(7, -5, 0), "child global position didn't move correctly")

	child:moveToGlobal(0, 0)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't stay in place")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't move correctly")

end

function coretest.testGlobalRotation(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	assert(object.globalRotation == 0, "default object rotation wasn't 0")
	assert(child.globalRotation == 0, "default child global rotation wasn't 0")


	--[[GameObject.rotate]]
	object:rotate(45)
	assert(object.globalRotation == 45, "object wasn't correctly globally rotated to 45")
	assert(child.globalRotation == 45, "child wasn't correctly globally rotated to 45")

	child:rotate(45)
	assert(object.globalRotation == 45, "object didn't maintain global rotation")
	assert(child.globalRotation == 90, "child wasn't correctly globally rotated to 90")

	object:rotate(-40)
	assert(object.globalRotation == 5, "object wasn't correctly globally rotated to 5")
	assert(child.globalRotation == 50, "child wasn't correctly globally rotated to 50")

	child:rotate(-20)
	assert(object.globalRotation == 5, "object didn't maintain global rotation")
	assert(child.globalRotation == 30, "child wasn't correctly globally rotated to 30")

	object:rotate(360)
	child:rotate(-360)
	assert(object.globalRotation == 5, "object didn't maintain global rotation")
	assert(child.globalRotation == 30, "child didn't maintain global rotation")


	--[[GameObject.rotate]]
	object:rotateTo(0)
	child:rotateTo(0)
	assert(object.globalRotation == 0, "object wasn't correctly globally rotated to 0")
	assert(child.globalRotation == 0, "child wasn't correctly globally rotated to 0")

	object:rotateTo(70)
	assert(object.globalRotation == 70, "object wasn't correctly globally rotated to 70")
	assert(child.globalRotation == 70, "child wasn't correctly globally rotated to 70")

	child:rotateTo(80)
	assert(object.globalRotation == 70, "object didn't maintain global rotation")
	assert(child.globalRotation == 150, "child wasn't correctly globally rotated to 150")

	object:rotateTo(360)
	child:rotateTo(-361)
	assert(object.globalRotation == 0, "object wasn't correctly globally rotated to 0")
	assert(child.globalRotation == 359, "child wasn't correctly globally rotated to 359")

end

function coretest.testGameObjectRemovalWithoutChildren(scene)

	--[[GameScene:removeGameObject]]
	local object = lass.GameObject(scene, "testing object")

	scene:removeGameObject(object)
	assert(object.active == false, "object was not deactivated")
	assert(searchTreeDepth(scene.children, object) == nil, "object was not removed from scene")

	-- a second call should produce no error
	scene:removeGameObject(object)


	--[[GameObject:destroy]]
	object = lass.GameObject(scene, "testing object")

	object:destroy()
	assert(object.active == false, "object was not deactivated")
	assert(searchTreeDepth(scene.children, object) == nil, "object was not removed from scene")

	-- a second call should produce no error
	object:destroy()


	--[[GameScene:removeChild]]
	object = lass.GameObject(scene, "testing object")

	scene:removeChild(object)
	assert(object.active == true, "object was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, object) == nil, "object was not removed from scene children")


	--[[GameObject:removeChild]]
	object = lass.GameObject(scene, "testing object")

	object:removeChild(object)
	assert(object.active == true, "object was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, object) == 1, "object was incorrectly removed from scene children")

end

function coretest.testGameObjectRemovalWithChildren(scene)

	--[[GameScene:removeGameObject]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	scene:removeGameObject(object, true)
	assert(child.active == false, "child was not deactivated")
	assert(searchTreeDepth(scene.children, child) == nil, "child was not removed from scene")
	-- assert(searchTreeDepth(object.children, child) == nil, "child was not removed from object")

	object = lass.GameObject(scene, "test")
	child = lass.GameObject(scene, "test child")
	object:addChild(child)

	scene:removeGameObject(object, false)
	assert(child.active == true, "child was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, child) == 1, "child was not made a child of the scene")
	assert(searchTreeCount(scene.children, child) == 1, "child reference count is incorrect")

	scene:removeGameObject(child)
	assert(child.active == false, "child was not deactivated")
	assert(searchTreeDepth(scene.children, child) == nil, "child was not removed from scene")
	-- assert(searchTreeDepth(object.children, child) == nil, "child was not removed from object")


	--[[GameObject:destroy]]
	object = lass.GameObject(scene, "test")
	child = lass.GameObject(scene, "test child")
	object:addChild(child)

	object:destroy(true)
	assert(child.active == false, "child was not deactivated")
	assert(searchTreeDepth(scene.children, child) == nil, "child was not removed from scene")

	object = lass.GameObject(scene, "test")
	child = lass.GameObject(scene, "test child")
	object:addChild(child)

	object:destroy(false)
	assert(child.active == true, "child was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, child) == 1, "child was not made a child of the scene")
	assert(searchTreeCount(scene.children, child) == 1, "child reference count is incorrect")

	-- this shouldn't do anything, since the object was already destroyed
	object:destroy(true)
	assert(child.active == true, "child was incorrectly deactivated")

	child:destroy()
	assert(child.active == false, "child was not deactivated")
	assert(searchTreeDepth(scene.children, child) == nil, "child was not removed from scene")

	-- a second call should produce no error
	child:destroy()


	--[[GameScene:removeChild]]
	object = lass.GameObject(scene, "test")
	child = lass.GameObject(scene, "test child")
	object:addChild(child)

	scene:removeChild(object, true)
	assert(child.active == true, "child was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, child) == nil, "child was not removed from scene")
	assert(searchTreeDepth(object.children, child) == 1, "child was incorrectly removed from object")

	object = lass.GameObject(scene, "test")
	child = lass.GameObject(scene, "test child")
	object:addChild(child)

	scene:removeChild(child)
	assert(child.active == true, "child was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, child) == 2,
		"child was removed from scene children, even though it's not a direct child")
	assert(searchTreeDepth(object.children, child) == 1, "child was incorrectly removed from object")

	scene:removeChild(object, false)
	assert(child.active == true, "child was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, child) == 1, "child was not made a child of the scene")
	assert(searchTreeCount(scene.children, child) == 1, "child reference count is incorrect")
	assert(searchTreeDepth(object.children, child) == 1, "child was incorrectly removed from object")

	scene:removeChild(child)
	assert(child.active == true, "child was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, child) == nil, "child was not removed from scene")


	--[[GameObject:removeChild]]
	object = lass.GameObject(scene, "test")
	child = lass.GameObject(scene, "test child")
	object:addChild(child)

	child:removeChild(child)
	assert(child.active == true, "child was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, child) == 2, "child was incorrectly removed from scene children")

	object:removeChild(child)
	assert(child.active == true, "child was incorrectly deactivated")
	assert(searchTreeDepth(scene.children, child) == nil, "child was not removed from scene")
	assert(searchTreeDepth(object.children, child) == nil, "child was not removed from object")

end

return coretest