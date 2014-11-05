-- lass.lua
-- an object/component framework for love2d, inspired by unity
-- decky coss (cosstropolis.com)

local class = require("lass.class")
local utils = require("lass.utils")

--[[
Vector2
]]

--[[internal]]

local function assertOperandsHaveXandY(a, b, otherAllowedType, otherAllowedTypePosition)

	local typeA, typeB = type(a), type(b)

	if not otherAllowedType then
		assert(typeA == "table" and typeB == "table", "both operands must be tables")
		assert(a.x and a.y and b.x and b.y, "both operands must have x and y defined")
	else
		assert(type(otherAllowedType) == "string", tostring(otherAllowedType) .. " is not string")
		assert(typeA == "table", "first argument must be table")
		assert(typeB == "table" or typeB == otherAllowedType,
			"second argument must be table or " .. otherAllowedType)
		assert(a.x and a.y, "table arguments must have x and y defined")
		if typeB == "table" then
			assert(b.x and b.y, "table arguments must have x and y defined")
		end
	end
end

--[[public]]

local Vector2 = class.define(function(self, x, y)

	if type(x) == "table" then
		y = x.y
		x = x.x
	end

	self.x = x or 0
	self.y = y or 0
end)

function Vector2.__add(a, b)

	assertOperandsHaveXandY(a, b)
	return Vector2(a.x+b.x, a.y+b.y)
end

function Vector2.__sub(a, b)

	assertOperandsHaveXandY(a, b)
	return Vector2(a.x-b.x, a.y-b.y)
end

function Vector2.__mul(a, b)

	local scalar = nil
	local vector = nil

	if type(a) == "table" then
		vector = a
		scalar = b
	else
		scalar = a
		vector = b
	end

	--ISSUE: this allows two vectors to be multiplied - needs a fix
	assertOperandsHaveXandY(vector, scalar, "number")

	return Vector2(vector.x * scalar, vector.y * scalar)
end

function Vector2:__tostring()
	return string.format("{x=%.2f, y=%.2f}", self.x, self.y)
end

function Vector2:sqrMagnitude(origin)
	--return the square magnitude of a vector relative to origin (0,0 by default)
	--this can also be used as a class/static function (i.e., Vector3.sqrMagnitude(a, b))

	assertOperandsHaveXandY(self, origin, "nil")
	local vec = self - Vector2(origin)

	return vec.x^2 + vec.y^2
end

function Vector2:magnitude(origin)
	--return the square magnitude of a vector relative to origin (0,0 by default)
	--this can also be used as a class/static function (i.e., Vector2.magnitude(a, b))

	return math.sqrt(Vector2.sqrMagnitude(self, origin))
end

function Vector2:rotate(angle, useRadians)
	--return the vector rotated around the origin by [angle] degrees or radians
	--
	--although the vector will be rotated clockwise, any graphics renderer using this vector
	--will appear to rotate counterclockwise by default. this is because love2d's y-axis is
	--"reversed" - y values are highest at the bottom of the screen. set invertYAxis to true
	--in your scene settings to make the rotation appear clockwise.

	if not useRadians then
		angle = -(angle/180) * math.pi
	end

	return Vector2({
		x = (self.x * math.cos(angle)) - (self.y * math.sin(angle)),
		y = (self.x * math.sin(angle)) + (self.y * math.cos(angle))		
	})
end

function Vector2:angle(useRadians)
	--return the angle of this vector relative to the origin

	local c = 1
	if not useRadians then
		c = 180/math.pi
	end

	--tangent = opposite / adjacent
	return math.atan(self.y / self.x) * c
end

function Vector2:dot(other)

	return self.x * other.x + self.y * other.y
end

function Vector2:project(direction)
	--project this vector onto a direction vector

	assertOperandsHaveXandY(self, direction)
	return (self:dot(direction) / Vector2.dot(direction, direction)) * direction
end

--[[
Vector3
]]

--[[internal]]

local function sanitizeOperandZAxis(a, b, fallbackValue)
	--if a.z or b.z is nil, set it to fallbackValue
	--(assumes that you have already asserted a and b are Vector2)

	fallbackValue = fallbackValue or 0
	a.z = a.z or fallbackValue
	b.z = b.z or fallbackValue
	return a, b
end

--[[public]]

local Vector3 = class.define(Vector2, function(self, x, y, z)

	Vector2.init(self, x, y)

	if type(x) == "table" then
		z = x.z
	end

	self.z = z or 0
end)

function Vector3.__add(a, b)

	assertOperandsHaveXandY(a, b)
	a, b = sanitizeOperandZAxis(a, b)
	return Vector3(a.x+b.x, a.y+b.y, a.z+b.z)
end

function Vector3.__sub(a, b)

	assertOperandsHaveXandY(a, b)
	a, b = sanitizeOperandZAxis(a, b)
	return Vector3(a.x+b.x, a.y+b.y, a.z+b.z)
end

function Vector3:sqrMagnitude(origin)
	--return the square magnitude of a vector relative to origin (0,0 by default)
	--this can also be used as a class/static function (i.e., Vector3.sqrMagnitude(a, b))

	assertOperandsHaveXandY(self, origin, "nil")
	local vec = self - Vector3(origin)

	return vec.x^2 + vec.y^2 + vec.z^2
end

function Vector3:magnitude(origin)
	--return the magnitude of a vector relative to origin (0,0 by default)
	--this can also be used as a class/static function (i.e., Vector3.magnitude(a, b))

	return math.sqrt(Vector3.sqrMagnitude(self, origin))
end

function Vector3:rotate(angle, useRadians)
	--this is functionally identical to Vector2:rotate except it leaves in the original z value
	--(Vector2:rotate simply discards it)

	local vec = Vector2.rotate(self, angle, useRadians)
	vec.z = self.z
	return vec
end

--[[
Component
]]

local Component = class.define(function(self, properties) 

	self.gameObject = nil
	for k, v in pairs(properties) do
		self[k] = v
	end
end)

function Component:awake()
	--callback function that is invoked whenever Component is attached to a GameObject
end

function Component:update(dt) end

--[[
GameEntity
]]

local GameEntity = class.define(function(self, transform, parent)

	if type(transform) == "table" then
		self.transform = transform
	else
		self.transform = {}
	end

	--initialize position and size settings
	for property, defaultAxisValue in pairs({position=0, size=1}) do

		local vec = {}

		--account for empty tables
		for _, axis in ipairs({"x", "y", "z"}) do
			if type(self.transform[property]) ~= "table" then
				vec[axis] = defaultAxisValue
			else
				vec[axis] = self.transform[property][axis] or defaultAxisValue
			end
		end

		self.transform[property] = Vector3(vec)
	end

	--initialize rotation
	self.transform.rotation = self.transform.rotation or 0

	self.children = {}

	if parent then
		parent:addChild(self)
	end

	self:maintainTransform()
end)

function GameEntity:addChild(child, trackParent)

	assert(class.instanceof(child, GameEntity), "child must be GameEntity")
	assert(child ~= self, "circular reference: cannot add self as child")

	if trackParent == nil then
		trackParent = true
	end

	if self.children then
		self.children[#self.children + 1] = child
	else
		self.children = {child}
	end

	if trackParent then
		child.parent = self
	end
end

function GameEntity:removeChild(child)

	local index = utils.indexof(self.children, child)
	if index then
		table.remove(self.children, index)
	end
end

function GameEntity:update(dt, firstUpdate )

	self:maintainTransform()

	--update children
	for i, child in ipairs(self.children) do
		child:update(dt, firstUpdate)
	end
end

function GameEntity:maintainTransform()
	--maintain global position and rotation
	--NOTE: only GameEntity:init() and GameEntity:update() should call this function directly

	--clamp rotation between 0 and 360 degrees (e.g., -290 => 70)
	self.transform.rotation = self.transform.rotation % 360

	if self.parent and self.parent ~= {} then
		local p = self.parent.globalTransform
		local t = self.transform

		self.globalTransform = {
			position = p.position + t.position:rotate(p.rotation),
			size = Vector3({
				x = t.size.x * p.size.x,
				y = t.size.y * p.size.y,
				z = t.size.z * p.size.z,
			}),
			rotation = t.rotation + p.rotation
		}
	else
		self.globalTransform = self.transform
	end
end

function GameEntity:move(x, y, z)
	self.transform.position = self.transform.position + Vector3(x, y, z)
end

function GameEntity:moveTo(x, y, z)
	self.transform.position = Vector3(x, y, z)
end

function GameEntity:rotate(angle)
	self.transform.rotation = self.transform.rotation + angle
end

function GameEntity:resize(x, y, z, allowNegativeSize)

	self.transform.size = self.transform.size + Vector3(x, y, z)

	if not allowNegativeSize then
		for axis, value in pairs(self.transform.size) do
			if value < 0 then self.transform.size[axis] = 0 end
		end
	end
end

--[[
GameObject
]]

--[[internal]]
local function getComponents(self, componentType, num)
	--shared function for finding components in a gameObject

	if type(componentType) == "string" then
		componentType = require(componentType)
	end

	found = {}
	for i, component in ipairs(self.components) do
		if component:instanceof(componentType) then
			found[#found + 1] = component
		end
		if #found >= num then
			return found
		end
	end

	return found
end

--[[public]]

local GameObject = class.define(GameEntity, function(self, gameScene, name, transform, parent)

	name = name or ""
	self.name = string.format(name)

	GameEntity.init(self, transform)

	--if parent is specified, it must be a GameObject
	if parent then
		assert(class.instanceof(parent, GameObject), "parent must be GameObject")

		parent:addChild(self)
	else
		gameScene:addChild(self, false)
	end

	self.components = {}

	gameScene:addGameObject(self)
end)

function GameObject:update(dt, firstUpdate)

	for i, component in ipairs(self.components) do
		component:update(dt, firstUpdate)
	end

	self.base.update(self, dt, firstUpdate)
end

function GameObject:draw()
	for i, component in ipairs(self.components) do

		--usually this function would only be called if component.draw exists.
		--however, it might not exist (the component might have been removed/deactivated),
		--so we'll check
		if component.draw then component:draw() end
	end
end

function GameObject:mousepressed(x, y, button)
	for i, component in ipairs(self.components) do
		if component.mousepressed then component:mousepressed(x, y, button) end
	end

	for i, child in ipairs(self.children) do
		child:mousepressed(x, y, button)
	end
end

function GameObject:isDrawable()
	--returns true if this GameObject contains a component with a draw() function

	for i, component in ipairs(self.components) do
		if component.draw then return true end
	end

	return false
end

function GameObject:addChild(child)

	--if child is at the top of the hierarchy, push it down
	child.gameScene:removeChild(child)

	if class.instanceof(child.parent, GameObject) then
		child.parent:removeChild(child)
	end
	self.base.addChild(self, child)
end

function GameObject:addComponent(component)

	--status, result = pcall(component.is_a, component, Component)
	-- assert(class.instanceof(component, Component), "component must be Component")

	if self.components then
		self.components[#self.components + 1] = component
	else
		self.components = {components}
	end

	component.gameObject = self

	component:awake()
end

function GameObject:getComponent(componentType)
	--fetch an instance of componentType that is attached to this object
	--componentType may be a Component class, or the name of the module where the class is found

	return getComponents(self, componentType, 1)[1]
end

function GameObject:getComponents(componentType)
	--fetch all instances of componentType that are attached to this object
	--componentType may be a Component class, or the name of the module where the class is found

	return getComponents(self, componentType)
	-- found = {}
	-- for i, component in ipairs(self.components) do
	-- 	if component:instanceof(componentType) then
	-- 		found[#found + 1] = component
	-- 	end
	-- end

	-- return found
end

--[[
GameScene
]]

--[[internal]]

local function buildObjectTree(scene, object)

	--create gameObject and add it to scene
	local gameObject = GameObject(scene, object.name, object.transform)

	--create and add components
	for i, comp in ipairs(object.components) do
		local componentClass = require(comp.script)
		gameObject:addComponent(componentClass(comp.properties))
	end

	--build children
	if object.children then
		for i, child in ipairs(object.children) do
			gameObject:addChild(buildObjectTree(scene, child))
		end
	end

	return gameObject
end

local function createSettingsTable(settings)

	settings = settings or {}

	for sectionName, section in pairs(require("lass.defaults")) do
		if not settings[sectionName] then
			settings[sectionName] = section
		else
			for optionName, option in pairs(section) do
				settings[sectionName][optionName] = settings[sectionName][optionName] or option
			end
		end
	end

	return settings
end

--[[public]]

local GameScene = class.define(GameEntity, function(self, transform)

	self.gameObjects = {}
	GameEntity.init(self, transform)
end)

function GameScene:load(src)
	--load objects and settings from a table or module

	local typeS = type(src)
	local source = ""

	if typeS == "string" then
		source = src
		src = require(src)
	else
		assert(typeS == "table", "src must be file name, module name, or table")
		assert(src.gameObjects, "src.gameObjects is required")
		assert(src.settings, "src.settings is required")
	end

	self:init()
	self.source = source

	--build game objects
	for i, object in ipairs(src.gameObjects) do
		buildObjectTree(self, object)
	end

	self.settings = createSettingsTable(src.settings)
	self:applySettings()
end

function GameScene:applySettings()

	--window
	love.window.setMode(self.settings.window.width, self.settings.window.height)

	--graphics
	love.graphics.setBackgroundColor(self.settings.graphics.backgroundColor)
end

function GameScene:addGameObject(gameObject)
	--add a GameObject to this GameScene (call this from gameObject constructor)

	--local status, result = pcall(gameObject.is_a, gameObject, GameObject)
	assert(class.instanceof(gameObject, GameObject), "gameObject must be GameObject")

	gameObject.gameScene = self
	table.insert(self.gameObjects, gameObject)

	--print("added " .. gameObject.name .. " to scene at " .. gameObject.transform.position.x)

end

function GameScene:removeGameObject(gameObject)

	local index = utils.indexof(self.gameObjects, gameObject)
	if index then
		table.remove(self.gameObjects, index)
	end

	for k,v in pairs(gameObject) do
		gameObject[k] = nil
	end
end

function GameScene:update(dt)
	--update all children (top-level game objects) of the scene

	self.base.update(self, dt, not self.finishedFirstUpdate)
	if not self.finishedFirstUpdate then
		self.finishedFirstUpdate = true
	end
end

function GameScene:draw()

	local drawables = {}
	local indices = {}

	--collect all drawable objects into buckets
	for i, object in ipairs(self.gameObjects) do
		if object:isDrawable() then
			local bucket = drawables[object.transform.position.z]
			if bucket then
				bucket[#bucket+1] = object
			else
				drawables[object.transform.position.z] = {object}
			end
		end
	end

	--sort the z indices
	for index in pairs(drawables) do
		indices[#indices+1] = index
	end
	table.sort(indices)

	--draw
	for i, index in pairs(indices) do
		for j, drawable in pairs(drawables[index]) do
			drawable:draw()
		end
	end
end

function GameScene:mousepressed(x, y, button)
	for i, child in ipairs(self.children) do
		child:mousepressed(x, y, button)
	end
end

return {
	Vector2 = Vector2,
	Vector3 = Vector3,
	GameEntity = GameEntity,
	GameScene = GameScene,
	GameObject = GameObject,
	Component = Component
}
