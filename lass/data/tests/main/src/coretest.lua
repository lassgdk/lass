local lass = require("lass")
local geometry = require("lass.geometry")

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

function coretest.testGameObjectChildTransform

	--[[setup]]

end

return coretest