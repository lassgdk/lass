local lass = require("lass")
local geometry = require("lass.geometry")

local coretest = {}
coretest.tests = {
	"testGameobjectMovement"
}

function coretest.testGameobjectMovement(scene)

	--setup

	local object = lass.GameObject(scene, "test")

	assert(
		object.transform.position == geometry.Vector3(0,0,0),
		"transform position should be 0,0,0 but is " .. tostring(object.transform.position)
	)
	assert(
		object.globalTransform.position == geometry.Vector3(0,0,0),
		"global transform position should be 0,0,0 but is " .. tostring(object.globalTransform.position)
	)

	object:move(5,5)
	object:move(0,1)
	assert(
		object.transform.position == geometry.Vector3(5,6,0),
		"transform position should be 5,6,0 but is " .. tostring(object.transform.position)
	)

	object:moveTo(0,0)
	assert(
		object.transform.position == geometry.Vector3(0,0,0),
		"transform position should be 0,0,0 but is " .. tostring(object.transform.position)
	)

end

return coretest