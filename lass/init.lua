-- lass.lua
-- an object/component model for love2d, inspired by unity
-- decky coss (cosstropolis.com)

require("lass.class")

--[[
GameEntity
]]

GameEntity = class(function(self, transform, parent)

	if type(transform) == "table" then
		self.transform = transform
	else
		self.transform = {}
	end

	self.transform.x = self.transform.x or 0
	self.transform.y = self.transform.y or 0
	self.transform.z = self.transform.z or 0
	self.transform.rotation = self.transform.rotation or 0

	self.children = {}

	if parent then
		parent:addChild(self)
	end

	self:maintainTransform()
end)

function GameEntity:addChild(child, trackParent)

	assert(instanceof(child, GameEntity), "child must be GameEntity")
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

	-- local offset = 0
	-- for i, entity in ipairs(self.children) do
	-- 	if entity == child then
	-- 		self.children[i] = nil
	-- 		offset = 1
	-- 	end
	-- 	self.children[i] = self.children[i+offset]
	-- end

	local index = indexof(self.children, child)
	if index then
		table.remove(self.children, index)
	end
end

function GameEntity:update(dt)

	self:maintainTransform()

	--update children
--	if self.children and updateChildren then
	for i, child in ipairs(self.children) do
		child:update(dt)
	end
--	end
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
			z = t.z + p.z,
			rotation = t.rotation + p.rotation,

			--adjust position based on rotation around the parent
			--normally this formula would rotate CCW, but love2d's y-axis is reversed
			x = p.x + (t.x * math.cos(angle)) - (t.y * math.sin(angle)),
			y = p.y + (t.x * math.sin(angle)) + (t.y * math.cos(angle))
		}
	else
		self.globalTransform = self.transform
	end
end

--[[
GameScene
]]

GameScene = class(GameEntity, function(self, transform)

	self.gameObjects = {}
	GameEntity.init(self, transform)
end)

function GameScene:addGameObject(gameObject)
	--add a GameObject to this GameScene (call this from gameObject constructor)

	--local status, result = pcall(gameObject.is_a, gameObject, GameObject)
	assert(instanceof(gameObject, GameObject), "gameObject must be GameObject")

	gameObject.gameScene = self
	table.insert(self.gameObjects, gameObject)

	print("added " .. gameObject.name .. " to scene at " .. gameObject.transform.x)

end

function GameScene:removeGameObject(gameObject)

	local index = indexof(self.gameObjects, gameObject)
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
			--object:draw()
			local bucket = drawables[object.transform.z]
			if bucket then
				bucket[#bucket+1] = object
			else
				drawables[object.transform.z] = {object}
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
			-- print('blah')
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
GameObject
]]

GameObject = class(GameEntity, function(self, gameScene, name, transform, parent)

	name = name or ""
	self.name = string.format(name)

	GameEntity.init(self, transform)

	--if parent is specified, it must be a GameObject
	if parent then
		status, result = pcall(parent.is_a, parent, GameObject)
		assert(status and result, "parent must be GameObject")

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
	if instanceof(child.parent, GameObject) then
		child.parent:removeChild(child)
	end
	self._base.addChild(self, child)
end

function GameObject:addComponent(component)

	status, result = pcall(component.is_a, component, Component)
	assert(status and result, "component must be Component")

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

function GameObject:getGlobalTransform()
	if parent then
		p = self.parent.getGlobalTransform()
		return {
			x = self.transform.x + p.x,
			y = self.transform.y + p.y,
			z = self.transform.z + p.z,
			rotation = self.transform.rotation + p.rotation
		}
	else
		return self.transform
	end
end

function GameObject:getHighestTransform()
	if parent then
		return parent:getHighestTransform()
	end
	return self.transform
end

function GameObject:move(x, y, z)

	if type(x) == "table" then
		z = x.z
		y = x.y
		x = x.x
	end

	self.transform.x = self.transform.x + x
	self.transform.y = self.transform.y + y
	self.transform.z = self.transform.z + (z or 0)
end

function GameObject:moveTo(x, y, z)

	if type(x) == "table" then
		z = x.z
		y = x.y
		x = x.x
	end
	self.transform.x = x
	self.transform.y = y
	self.transform.z = z or self.transform.z
end

--[[
Component
]]

Component = class(function(self, properties) 

	self.gameObject = {}
	for k, v in pairs(properties) do
		self[k] = v
	end
end)

function Component:update(dt) end

--[[
utils
]]

function distance2D(point1, point2)

	for i, point in ipairs({point1, point2}) do
		if point.x == nil then
			point.x = point[1]
			point.y = point[2]
		end
	end
	return math.sqrt((point2.x-point1.x)^2 + (point2.y - point1.y)^2)
end

function indexof(list, value)
	--find first index of value in numeric table

	for i, entity in ipairs(list) do
		if entity == value then
			return i
		end
	end
end
