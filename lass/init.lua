-- lass.lua
-- an object/component framework for love2d, inspired by unity
-- decky coss (cosstropolis.com)

local class = require("lass.class")
local collections = require("lass.collections")
local geometry = require("lass.geometry")

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

function Component:update(dt, firstUpdate) end

--[[
GameEntity
]]

--[[internal]]

function maintainTransform(self)
	--maintain global position and rotation
	--NOTE: only GameEntity:init() and GameEntity:update() should call this function directly

	--clamp rotation between 0 and 360 degrees (e.g., -290 => 70)
	self.transform.rotation = self.transform.rotation % 360

	if self.parent and next(self.parent) ~= nil then
		local p = self.parent.globalTransform
		local t = self.transform

		self.globalTransform = geometry.Transform({
			position = p.position, 
			size = geometry.Vector3({
				x = t.size.x * p.size.x,
				y = t.size.y * p.size.y,
				z = t.size.z * p.size.z,
			}),
			rotation = t.rotation + p.rotation
		})

		self.globalTransform.position = self.globalTransform.position + geometry.Vector3({
			x = t.position.x * p.size.x,
			y = t.position.y * p.size.y,
			z = t.position.y * p.size.y
		}):rotate(p.rotation)
	else
		self.globalTransform = self.transform
	end
end

--[[public]]

local GameEntity = class.define(function(self, transform, parent)

	if class.instanceof(transform, geometry.Transform) then
		self.transform = transform
	else
		self.transform = geometry.Transform(transform)
	end

	self.children = {}

	if parent then
		parent:addChild(self)
	end

	maintainTransform(self)
end)

function GameEntity:addChild(child, trackParent)

	-- for k,v in pairs(child) do print(k,v) end
	-- print(type(GameEntity))

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

	local index = collections.index(self.children, child)
	if index then
		table.remove(self.children, index)
	end
end

function GameEntity:update(dt, firstUpdate)

	--update children
	for i, child in ipairs(self.children) do
		child:update(dt, firstUpdate)
	end
end

function GameEntity:move(x, y, z)
	self.transform.position = self.transform.position + geometry.Vector3(x, y, z)
end

function GameEntity:moveTo(x, y, z)
	self.transform.position = geometry.Vector3(x, y, z)
end

function GameEntity:rotate(angle)
	self.transform.rotation = self.transform.rotation + angle
end

function GameEntity:resize(x, y, z, allowNegativeSize)

	self.transform.size = self.transform.size + geometry.Vector3(x, y, z)

	if not allowNegativeSize then
		for axis, value in pairs(self.transform.size) do
			if value < 0 then self.transform.size[axis] = 0 end
		end
	end
end

--callback functions
for i, f in ipairs({
	"errhand",
	"focus",
	"keypressed",
	"keyreleased",
	"mousefocus",
	"mousepressed",
	"mousereleased",
	"quit",
	"resize",
	"textinput",
	"threaderror",
	"visible"
}) do
	GameEntity[f] = function(self, ...)
		for i, child in ipairs(self.children) do
			child[f](child, ...)
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

	maintainTransform(self)

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

--callback functions
for i, f in ipairs({
	"errhand",
	"focus",
	"keypressed",
	"keyreleased",
	"mousefocus",
	"mousepressed",
	"mousereleased",
	"quit",
	"resize",
	"textinput",
	"threaderror",
	"visible"
}) do
	GameObject[f] = function(self, ...)
		for i, component in ipairs(self.components) do
			if component[f] then
				component[f](component, ...)
			end
		end
		self.base[f](self, ...)
	end
end

--[[
GameScene
]]

--[[internal]]

local function mergeComponentLists(prefabComponents, overrides)

	assert(prefabComponents, "prefabComponents must be list")

	local components = collections.deepcopy(prefabComponents)

	if not overrides then
		return components
	end

	local overrides = collections.deepcopy(overrides)

	print(#overrides)
	for k,v in ipairs(overrides) do
		print(v.script)
		for _k, _v in pairs(v.arguments) do
			if type(_v) == "table" then
				for __k, __v in pairs(_v) do
					print (_k, __k, __v)
				end
			else
				print(_k, _v)
			end
		end
	end

	local found = {}

	for i, comp in ipairs(overrides) do
		local orig = nil

		if not found[comp.script] then
			found[comp.script] = collections.indices(components, comp.script, function(x)
				return x.script
			end)
		--if we found an override for a component that doesn't exist in the original
		elseif next(found[comp.script]) == nil then
			error("component not found in original prefab")
		end

		orig = components[table.remove(found[comp.script], 1)]

		print(i)
		print(orig)

		--override settings of the first instance of this component
		for argkey, argvalue in pairs(comp.arguments) do

			print(argkey, argvalue)
			orig.arguments[argkey] = argvalue
		end
	end
	return components
end

local function buildObjectTree(scene, object)
	--build a game object and its children

	--create gameObject and add it to scene
	local gameObject = GameObject(scene, object.name, object.transform)


	if object.prefab and object.prefab ~= "" then
		local pf = require(object.prefab)
		print(gameObject.name, object.prefabComponents)

		for i, comp in ipairs(mergeComponentLists(pf.components, object.prefabComponents)) do

			-- --debug
			-- for k,v in pairs(comp.arguments) do
			-- 	print(comp.script, k, v)
			-- 	if type(v) == "table" then for _k, _v in pairs(v) do
			-- 		print(_k, _v)
			-- 	end end
			-- end

			gameObject:addComponent(require(comp.script)(comp.arguments))
		end
	end

	--create and add components
	if object.components then
		for i, comp in ipairs(object.components) do
			local componentClass = require(comp.script)
			gameObject:addComponent(componentClass(comp.arguments))
		end
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

	assert(class.instanceof(gameObject, GameObject), "gameObject must be GameObject")

	gameObject.gameScene = self
	table.insert(self.gameObjects, gameObject)

	--print("added " .. gameObject.name .. " to scene at " .. gameObject.transform.position.x)

end

function GameScene:removeGameObject(gameObject)

	local index = collections.index(self.gameObjects, gameObject)
	if index then
		table.remove(self.gameObjects, index)
	end

	for k,v in pairs(gameObject) do
		gameObject[k] = nil
	end
end

function GameScene:update(dt)
	--update all children (top-level game objects) of the scene

	maintainTransform(self)
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
			local bucket = drawables[object.globalTransform.position.z]
			if bucket then
				bucket[#bucket+1] = object
			else
				drawables[object.globalTransform.position.z] = {object}
			end
		end
	end

	--sort the z indices in reverse order (so highest are drawn first)
	for index in pairs(drawables) do
		indices[#indices+1] = index
	end
	table.sort(indices, function(a,b) return a > b end)

	--draw
	for i, index in pairs(indices) do
		for j, drawable in pairs(drawables[index]) do
			drawable:draw()
		end
	end
end

-- function GameScene:mousepressed(x, y, button)
-- 	for i, child in ipairs(self.children) do
-- 		child:mousepressed(x, y, button)
-- 	end
-- end

return {
	GameEntity = GameEntity,
	GameScene = GameScene,
	GameObject = GameObject,
	Component = Component
}
