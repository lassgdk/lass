-- lass.lua
-- an object/component model for love2d, inspired by unity
-- decky coss (cosstropolis.com)

class = require("lass.class")
utils = require("lass.utils")

local function getAxes(x, y, z)

	if type(x) == "table" then
		z = x.z
		y = x.y
		x = x.x
	end
	return x, y, z
end

--[[
Vector2
]]

--[[protected]]

local function assertOperandsAreVector2(a, b)

	assert(type(a) == "table" and type(b) == "table", "both operands must be tables")
	assert(a.x and a.y and b.x and b.y, "both operands must have x and y defined")
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

	assertOperandsAreVector2(a, b)
	return Vector2(a.x+b.x, a.y+b.y)
end

function Vector2.__sub(a, b)

	assertOperandsAreVector2(a, b)
	return Vector2(a.x-b.x, a.y-b.y)
end

--[[
Vector3
]]

--[[protected]]

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

	assertOperandsAreVector2(a, b)
	a, b = sanitizeOperandZAxis(a, b)
	return Vector3(a.x+b.x, a.y+b.y, a.z+b.z)
end

function Vector3.__sub(a, b)

	assertOperandsAreVector2(a, b)
	a, b = sanitizeOperandZAxis(a, b)
	return Vector3(a.x+b.x, a.y+b.y, a.z+b.z)
end

--[[
Component
]]

local Component = class.define(function(self, properties) 

	self.gameObject = {}
	for k, v in pairs(properties) do
		self[k] = v
	end
end)

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

function GameEntity:update(dt)

	self:maintainTransform()

	--update children
	for i, child in ipairs(self.children) do
		child:update(dt)
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
		local angle = (p.rotation/180) * math.pi

		self.globalTransform = {
			position = Vector3({
				z = t.position.z + p.position.z,

				--adjust position based on rotation around the parent
				--normally this formula would rotate CCW, but love2d's y-axis is inverted
				x = p.position.x + (t.position.x * math.cos(angle)) - (t.position.y * math.sin(angle)),
				y = p.position.y + (t.position.x * math.sin(angle)) + (t.position.y * math.cos(angle))
			}),
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

local GameObject = class.define(GameEntity, function(self, gameScene, name, transform, parent)

	name = name or ""
	self.name = string.format(name)

	print(transform.position.x)
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

function GameObject:update(dt)

	for i, component in ipairs(self.components) do
		component:update(dt)
	end

	self._base.update(self, dt)
end

function GameObject:isDrawable()
	--returns true if this GameObject contains a component with a draw() function

	for i, component in ipairs(self.components) do
		if component.draw then return true end
	end

	return false
end

function GameObject:draw()

	for i, component in ipairs(self.components) do
		if component.draw then component:draw() end
	end
end

-- function GameObject:addChild(child)

-- 	status, result = pcall(child.is_a, child, GameObject)
-- 	assert(status and result, "child must be GameObject")

-- 	self._base.addChild(self, child, true)
-- end

function GameObject:addChild(child)

	child.gameScene:removeChild(child)
	if class.instanceof(child.parent, GameObject) then
		child.parent:removeChild(child)
	end
	self._base.addChild(self, child)
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
end

function GameObject:getComponent(componentType)

	for i, component in ipairs(self.components) do
		if component:is_a(componentType) then
			return component
		end
	end
end

function GameObject:getComponents(componentType)

	found = {}
	for i, component in ipairs(self.components) do
		if component:is_a(componentType) then
			found[#found + 1] = component
		end
	end

	return found
end

--[[
GameScene
]]

local GameScene = class.define(GameEntity, function(self, transform)

	self.gameObjects = {}
	GameEntity.init(self, transform)
end)

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
	self._base.update(self, dt)
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

function GameScene:loadSceneFile(moduleName)

	local scene = require(moduleName)

	--reinvent yrself
	for k, v in pairs(self) do
		self[k] = nil
	end
	GameScene.init(self)

	--build game objects
	for i, object in ipairs(scene) do
		self:buildObjectTree(object)
	end
end

function GameScene:buildObjectTree(object)

	--create gameObject and add it to scene
	local gameObject = GameObject(self, object.name, object.transform)

	--create and add components
	for i, comp in ipairs(object.components) do
		local componentClass = require(comp._module)
		gameObject:addComponent(componentClass(comp.properties))
	end

	--build children
	if object.children then
		for i, child in ipairs(object.children) do
			gameObject:addChild(self:buildObjectTree(child))
		end
	end

	return gameObject
end

--[[
utils
]]

-- function distance2D(point1, point2)

-- 	for i, point in ipairs({point1, point2}) do
-- 		if point.x == nil then
-- 			point.x = point[1]
-- 			point.y = point[2]
-- 		end
-- 	end
-- 	return math.sqrt((point2.x-point1.x)^2 + (point2.y - point1.y)^2)
-- end

return {
	Vector2 = Vector2,
	Vector3 = Vector3,
	GameEntity = GameEntity,
	GameScene = GameScene,
	GameObject = GameObject,
	Component = Component
}
