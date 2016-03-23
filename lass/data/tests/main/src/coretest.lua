local lass = require("lass")
local geometry = require("lass.geometry")
local collections = require("lass.collections")

local coretest = {}

local function testLocalPosition(object, assertedPosition)

	local s1, s2 = tostring(assertedPosition), tostring(object.transform.position)
	assert(
		object.transform.position == assertedPosition,
		"local transform position should be" .. s1 .. " but is " .. s2
	)

end

local function testGlobalPosition(object, assertedPosition)

	local s1, s2 = tostring(assertedPosition), tostring(object.globalTransform.position)
	assert(
		object.globalTransform.position == assertedPosition,
		"global transform position should be" .. s1 .. " but is " .. s2
	)

end

function coretest.testGameObjectMovement(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")

	testLocalPosition(object, geometry.Vector3(0,0,0))
	testGlobalPosition(object, geometry.Vector3(0,0,0))


	--[[GameObject.move]]
	object:move(5,5)
	object:move(0,1)
	testLocalPosition(object, geometry.Vector3(5,6,0))
	testGlobalPosition(object, geometry.Vector3(5,6,0))

	object:move(-5,-6)
	testLocalPosition(object, geometry.Vector3(0,0,0))
	testGlobalPosition(object, geometry.Vector3(0,0,0))


	--[[GameObject.moveTo]]
	object:moveTo(-2,10)
	testLocalPosition(object, geometry.Vector3(-2,10,0))
	testGlobalPosition(object, geometry.Vector3(-2,10,0))

	object:moveTo(0,0)
	testLocalPosition(object, geometry.Vector3(0,0,0))
	testGlobalPosition(object, geometry.Vector3(0,0,0))


	--[[GameObject.moveGlobal]]
	object:moveGlobal(5,5)
	object:moveGlobal(0,1)
	testLocalPosition(object, geometry.Vector3(5,6,0))
	testGlobalPosition(object, geometry.Vector3(5,6,0))

	object:moveGlobal(-5,-6)
	testLocalPosition(object, geometry.Vector3(0,0,0))
	testGlobalPosition(object, geometry.Vector3(0,0,0))


	--[[GameObject.moveToGlobal]]
	object:moveToGlobal(-2,10)
	testLocalPosition(object, geometry.Vector3(-2,10,0))
	testGlobalPosition(object, geometry.Vector3(-2,10,0))

	object:moveToGlobal(0,0)
	testLocalPosition(object, geometry.Vector3(0,0,0))
	testGlobalPosition(object, geometry.Vector3(0,0,0))

end

function coretest.testGameObjectChildMovement(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	testLocalPosition(object, geometry.Vector3(0,0,0))
	testGlobalPosition(object, geometry.Vector3(0,0,0))


	--[[GameObject.move]]
	object:move(5,5)
	child:move(0,1)
	testLocalPosition(child, geometry.Vector3(0,1,0))
	testGlobalPosition(child, geometry.Vector3(5,6,0))

	object:move(-5,-5)
	child:move(0,-1)
	testLocalPosition(child, geometry.Vector3(0,0,0))
	testGlobalPosition(child, geometry.Vector3(0,0,0))


	--[[GameObject.moveTo]]
	object:moveTo(10,10)
	child:moveTo(-2,0)
	testLocalPosition(child, geometry.Vector3(-2,0,0))
	testGlobalPosition(child, geometry.Vector3(8,10,0))

	object:moveTo(0,0)
	testLocalPosition(child, geometry.Vector3(-2,0,0))
	testGlobalPosition(child, geometry.Vector3(-2,0,0))

	child:moveTo(0,0)
	testLocalPosition(child, geometry.Vector3(0,0,0))
	testGlobalPosition(child, geometry.Vector3(0,0,0))


	--[[GameObject.moveGlobal]]
	object:moveGlobal(5,5)
	child:moveGlobal(0,1)
	testLocalPosition(child, geometry.Vector3(0,1,0))
	testGlobalPosition(child, geometry.Vector3(5,6,0))

	object:moveGlobal(-5,-5)
	testLocalPosition(child, geometry.Vector3(0,1,0))
	testGlobalPosition(child, geometry.Vector3(0,1,0))

	child:moveGlobal(0,-1)
	testLocalPosition(child, geometry.Vector3(0,0,0))
	testGlobalPosition(child, geometry.Vector3(0,0,0))


	--[[GameObject.moveToGlobal]]
	object:moveToGlobal(-2,10)
	child:moveToGlobal(5,5)
	testLocalPosition(child, geometry.Vector3(7,-5,0))
	testGlobalPosition(child, geometry.Vector3(5,5,0))

	object:moveToGlobal(0,0)
	testLocalPosition(child, geometry.Vector3(7,-5,0))
	testGlobalPosition(child, geometry.Vector3(7,-5,0))

	child:moveToGlobal(0,0)
	testLocalPosition(child, geometry.Vector3(0,0,0))
	testGlobalPosition(child, geometry.Vector3(0,0,0))

end

function coretest.testGameObjectRotation(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")

	assert(object.transform.rotation == 0, "default object rotation wasn't 0")
	assert(object.globalTransform.rotation == 0, "default object global rotation wasn't 0")


	--[[GameObject.rotate]]
	object:rotate(45)
	assert(object.transform.rotation == 45, "object wasn't correctly rotated to 45")
	assert(object.globalTransform.rotation == 45, "object wasn't correctly globally rotated to 45")

	object:rotate(45)
	assert(object.transform.rotation == 90, "object wasn't correctly rotated to 90")
	assert(object.globalTransform.rotation == 90, "object wasn't correctly globally rotated to 90")

	object:rotate(-40)
	assert(object.transform.rotation == 50, "object wasn't correctly rotated to 50")
	assert(object.globalTransform.rotation == 50, "object wasn't correctly globally rotated to 50")

	object:rotate(360)
	assert(object.transform.rotation == 50, "object didn't maintain rotation")
	assert(object.globalTransform.rotation == 50, "object didn't maintain global rotation")

	object:rotate(-360)
	assert(object.transform.rotation == 50, "object didn't maintain rotation")
	assert(object.globalTransform.rotation == 50, "object didn't maintain global rotation")


	--[[GameObject.rotate]]
	object:rotateTo(0)
	assert(object.transform.rotation == 0, "object wasn't correctly rotated to 0")
	assert(object.globalTransform.rotation == 0, "object wasn't correctly globally rotated to 0")

	object:rotateTo(78)
	assert(object.transform.rotation == 78, "object wasn't correctly rotated to 78")
	assert(object.globalTransform.rotation == 78, "object wasn't correctly globally rotated to 78")

	object:rotateTo(192)
	assert(object.transform.rotation == 192, "object wasn't correctly rotated to 192")
	assert(object.globalTransform.rotation == 192, "object wasn't correctly globally rotated to 192")

	object:rotateTo(360)
	assert(object.transform.rotation == 0, "object wasn't correctly rotated to 0")
	assert(object.globalTransform.rotation == 0, "object wasn't correctly globally rotated to 0")

	object:rotateTo(-361)
	assert(object.transform.rotation == 359, "object wasn't correctly rotated to 359")
	assert(object.globalTransform.rotation == 359, "object wasn't correctly globally rotated to 359")

end

function coretest.testGameObjectChildRotation(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	assert(child.transform.rotation == 0, "default child rotation wasn't 0")
	assert(child.globalTransform.rotation == 0, "default child global rotation wasn't 0")


	--[[GameObject.rotate]]
	object:rotate(45)
	assert(child.transform.rotation == 0, "child rotation didn't stay at 0")
	assert(child.globalTransform.rotation == 45, "child wasn't correctly globally rotated to 45")

	child:rotate(45)
	assert(child.transform.rotation == 45, "child wasn't correctly rotated to 45")
	assert(child.globalTransform.rotation == 90, "child wasn't correctly globally rotated to 90")

	object:rotate(-40)
	assert(child.transform.rotation == 45, "child didn't maintain rotation")
	assert(child.globalTransform.rotation == 50, "child wasn't correctly globally rotated to 50")

	child:rotate(-20)
	assert(child.transform.rotation == 25, "child didn't maintain rotation")
	assert(child.globalTransform.rotation == 30, "child wasn't correctly globally rotated to 30")

	object:rotate(360)
	child:rotate(-360)
	assert(child.transform.rotation == 25, "child didn't maintain rotation")
	assert(child.globalTransform.rotation == 30, "child didn't maintain global rotation")


	--[[GameObject.rotate]]
	object:rotateTo(0)
	child:rotateTo(0)
	assert(child.transform.rotation == 0, "child wasn't correctly rotated to 0")
	assert(child.globalTransform.rotation == 0, "child wasn't correctly globally rotated to 0")

	object:rotateTo(70)
	assert(child.transform.rotation == 0, "child didn't maintain rotation")
	assert(child.globalTransform.rotation == 70, "child wasn't correctly globally rotated to 70")

	child:rotateTo(80)
	assert(child.transform.rotation == 80, "child wasn't correctly rotated to 80")
	assert(child.globalTransform.rotation == 150, "child wasn't correctly globally rotated to 150")

	object:rotateTo(360)
	child:rotateTo(-361)
	assert(child.transform.rotation == 359, "child wasn't correctly rotated to 359")
	assert(child.globalTransform.rotation == 359, "child wasn't correctly globally rotated to 359")

end

function coretest.testGlobalPosition(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't default correctly")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't default correctly")


	--[[GameObject.move]]
	object:move(5,5)
	child:move(0,1)
	assert(object.globalPosition == geometry.Vector3(5, 5, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(5, 6, 0), "child global position didn't move correctly")

	object:move(-5,-5)
	child:move(0,-1)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't move correctly")


	--[[GameObject.moveTo]]
	object:moveTo(10,10)
	child:moveTo(-2,0)
	assert(object.globalPosition == geometry.Vector3(10, 10, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(8, 10, 0), "child global position didn't move correctly")

	object:moveTo(0,0)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(-2, 0, 0), "child global position didn't move correctly")

	child:moveTo(0,0)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't stay in place")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't move correctly")


	--[[GameObject.moveGlobal]]
	object:moveGlobal(5,5)
	child:moveGlobal(0,1)
	assert(object.globalPosition == geometry.Vector3(5, 5, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(5, 6, 0), "child global position didn't move correctly")

	object:moveGlobal(-5,-5)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(0, 1, 0), "child global position didn't move correctly")

	child:moveGlobal(0,-1)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't stay in place")
	assert(child.globalPosition == geometry.Vector3(0, 0, 0), "child global position didn't move correctly")


	--[[GameObject.moveToGlobal]]
	object:moveToGlobal(-2,10)
	child:moveToGlobal(5,5)
	assert(object.globalPosition == geometry.Vector3(-2, 10, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(5, 5, 0), "child global position didn't move correctly")

	object:moveToGlobal(0,0)
	assert(object.globalPosition == geometry.Vector3(0, 0, 0), "object global position didn't move correctly")
	assert(child.globalPosition == geometry.Vector3(7, -5, 0), "child global position didn't move correctly")

	child:moveToGlobal(0,0)
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
	local numChildren = #scene.children
	local object = lass.GameObject(scene, "testing object")

	scene:removeGameObject(object)
	-- assert(object == nil, "object was not removed")
	assert(object.active == false, "object was not deactivated")
	assert(collections.index(scene.children, object) == nil, "object was not removed from scene")

end

function coretest.testGameObjectRemovalWithChildren(scene)

	--[[setup]]
	local object = lass.GameObject(scene, "test")
	local child = lass.GameObject(scene, "test child")
	object:addChild(child)

end

return coretest