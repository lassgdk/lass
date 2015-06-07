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

	self.globals = {}
end)

function Component:awake()
	--callback function that is invoked whenever Component is attached to a GameObject
end

function Component:update(dt, firstUpdate) end

function Component:globals()
	return self.gameObject.gameScene.globals
end

--[[
GameEntity
]]

--[[internal]]

local function maintainTransform(self)
	--maintain global position and rotation

	--clamp rotation between 0 and 360 degrees (e.g., -290 => 70)
	self.transform.rotation = self.transform.rotation % 360

	local t = self.transform
	local p = nil

	if self.parent and next(self.parent) ~= nil then
		p = self.parent.globalTransform
	elseif self.gameScene and next(self.gameScene) ~= nil then
		p = self.gameScene.transform
	else
		self.globalTransform = self.transform
		return
	end

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
		z = t.position.z * p.size.z
	}):rotate(p.rotation)
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

-- trackParent should normally be false if GameEntity is scene and child is GameObject
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
	"windowresize",
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

local function mergeComponentLists(prefabComponents, overrides)

	assert(prefabComponents, "prefabComponents must be list")

	local components = collections.deepcopy(prefabComponents)

	if not overrides then
		return components
	end

	local overrides = collections.deepcopy(overrides)

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

		--override settings of the first instance of this component
		for argkey, argvalue in pairs(comp.arguments) do

			orig.arguments[argkey] = argvalue
		end
	end
	return components
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

local function buildObjectTree(scene, object)
	--build a game object and its children

	--create gameObject and add it to scene
	local gameObject = GameObject(scene, object.name, object.transform)

	-- for k,v in pairs(object) do print(k,v) end

	if object.prefab and object.prefab ~= "" then
		local pf = love.filesystem.load(object.prefab)()
		-- local pf = require(object.prefab)

		for i, comp in ipairs(mergeComponentLists(pf.components, object.prefabComponents)) do
			gameObject:addComponent(require(comp.script)(comp.arguments))
		end
	end

	--create and add components
	if object.components then
		for i, comp in ipairs(object.components) do
			local componentClass = require(comp.script)
			-- print(componentClass, require("lass.builtins.graphics.RectangleRenderer"))

			-- print("hey", comp.script)
			-- for k,v in pairs(comp.arguments) do print(k,v) end

			-- print("checking inheritance for " .. object.name)
			assert(class.subclassof(componentClass, Component), comp.script.." does not return a Component")
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

--dot, not colon
function GameObject.fromPrefab(scene, prefab)
	return buildObjectTree(scene, prefab)
end

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
	component.gameScene = self.gameScene
	component.globals = self.gameScene.globals

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

function GameObject:detach()

	for i, component in ipairs(self.component) do
		if component.detach then
			component:detach()
		end
	end
end

function GameObject:move(x, y, z, stopOnCollide)

	local oldPosition = geometry.Vector3(self.transform.position)
	local newPosition

	if type(y) == "boolean" then
		newPosition = geometry.Vector3(x) + self.transform.position
		stopOnCollide = y
	else
		newPosition = geometry.Vector3(x, y, z) + self.transform.position
		stopOnCollide = stopOnCollide or false
	end

	self.transform.position = newPosition

	if not stopOnCollide then
		return true
	end

	if
		oldPosition.x == newPosition.x and
		oldPosition.y == newPosition.y and
		oldPosition.z == newPosition.z
	then
		return false
	end

	local collider = self:getComponent("lass.builtins.collision.Collider")
	if collider and collider.solid then
		local others = {}
		local collisions = {}

		-- we need to update the global transform for the collision detection to work immediately
		maintainTransform(self)

		for i, layer in ipairs(collider.layers) do
			-- print(#self.gameScene.globals.colliders[layer])
			others[layer] = collections.copy(self.gameScene.globals.colliders[layer])
		end

		for layerName, layer in pairs(others) do
			for i, other in ipairs(layer) do
				local r, d = collider:isCollidingWith(other)

				if other ~= collider and other.solid and r then
					-- if we were already colliding with other, check if overlap distance has increased
					if collider.collidingWith[other] and collider.collidingWith[other] < d then
						self.transform.position = oldPosition
						maintainTransform(self)
						return false
					-- only add colliders that we weren't already colliding with
					elseif not collider.collidingWith[other] then
						collisions[#collisions + 1] = other
					end
				end
			end
		end

		if #collisions < 1 then
			return true
		end

		local backward = true
		local lastBackward = backward
		local skip = newPosition - oldPosition
		local oldSkip

		skip = geometry.Vector2(skip.x/2, skip.y/2)
		for i, a in ipairs({"x", "y"}) do
			if skip[a] < 0 then
				skip[a] = math.ceil(skip[a])
			else
				skip[a] = math.floor(skip[a])
			end
		end
		local done = false
		local maintainSkip = false
		local counter = 0

		if skip.x == 0 and skip.y == 0 then
			self.transform.position = oldPosition
			maintainTransform(self)
			return false
		end

		while not done do
			if backward then
				self.transform.position = self.transform.position - skip
			else
				self.transform.position = self.transform.position + skip
			end

			self.transform.position.x = math.floor(self.transform.position.x)
			self.transform.position.y = math.floor(self.transform.position.y)

			maintainTransform(self)

			lastBackward = backward
			for i,c in ipairs(collisions) do
				if collider:isCollidingWith(c) then
					-- print("colliding")
					backward = true
					break
				end
				backward = false
			end

			local axesLessThanOne = 0
			if not maintainSkip then
				oldSkip = skip
				skip = geometry.Vector2(skip.x/2, skip.y/2)
				for i, a in ipairs({"x", "y"}) do
					if skip[a] < 0 then
						skip[a] = math.ceil(skip[a])
						if skip[a] > -1 then
							-- skip[a] = -1
							axesLessThanOne = axesLessThanOne + 1
						end
					elseif skip[a] > 0 then
						skip[a] = math.floor(skip[a])
						if skip[a] < 1 then
							-- skip[a] = 1
							axesLessThanOne = axesLessThanOne + 1
						end
					else
						axesLessThanOne = axesLessThanOne + 1
					end
				end
			end

			if axesLessThanOne == 2 then
				skip = oldSkip
				maintainSkip = true
			end
			if maintainSkip and backward and not lastBackward then
				done = true
			end

		end

		self.done = true
		return true, collisions

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
	"windowresize",
	"textinput",
	"threaderror",
	"visible",

	{"collisionenter", false},
	{"collisionexit", false}
}) do
	local super = true
	if type(f) == "table" then
		f = f[1]
		super = f[2]
	end

	GameObject[f] = function(self, ...)
		for i, component in ipairs(self.components) do
			if component[f] then
				component[f](component, ...)
			end
		end
		if super then
			self.base[f](self, ...)
		end
	end
end

--[[
GameScene
]]

--[[internal]]

local function createSettingsTable(settings, defaults)

	settings = settings or {}
	defaultsFallback = require("lass.defaults")
	defaults = defaults or defaultsFallback

	for sectionName, section in pairs(defaultsFallback) do

		if not settings[sectionName] then
			-- use defaults
			if defaults[sectionName] then
				settings[sectionName] = collections.deepcopy(defaults[sectionName])
			-- use defaults fallback, if different from defaults
			else
				settings[sectionName] = collections.deepcopy(section)
			end

		else
			if type(section) == "table" then
				for optionName, option in pairs(section) do
					local def
					if defaults[sectionName] then
						def = defaults[sectionName][optionName]
					end
					settings[sectionName][optionName] =	settings[sectionName][optionName] or def or option
				end
			--some "sections" are actually fields
			else
				settings[sectionName] = settings[sectionName] or defaults[sectionName] or section
			end
		end
	end

	return settings
end

local function maintainCollisions(self, colliderToCheck)

	--collision stuff
	local collisionData = {}
	local layers

	if colliderToCheck then
		layers = collections.set(colliderToCheck.layers)
	else
		layers = self.globals.colliders
	end

	for layerName, layer in pairs(layers) do

		-- local colliders = {}

		-- -- turn unordered set into an ordered list
		-- for collider in pairs(layer) do
		-- 	colliders[#colliders] = collider
		-- end

		if colliderToCheck then
			layer = self.globals.colliders[layerName]
		end

		-- use "staircase" method to check each collider against all subsequent colliders
		for i, collider in ipairs(layer) do
			-- print(i, collider.gameObject.name)

			if not collisionData[collider] then
				collisionData[collider] = {colliding={}, notColliding={}}
			end

			-- if j > #layer, the loop will be skipped
			for j = i+1, #layer do

				if not collisionData[layer[j]] then
					collisionData[layer[j]] = {colliding={}, notColliding={}}
				end

				local r, d = collider:isCollidingWith(layer[j])
				if r then
					collisionData[collider].colliding[layer[j]] = d
					collisionData[layer[j]].colliding[collider] = d
				else
					collisionData[collider].notColliding[layer[j]] = true
					collisionData[layer[j]].notColliding[collider] = true
				end
			end
		end
	end

	for collider, others in pairs(collisionData) do
		local enter = {}
		local exit = {}

		-- check collisions
		for other in pairs(others.colliding) do
			-- collision just started
			if not collider.collidingWith[other] then
				enter[#enter + 1] = other
			end
		end

		-- check non-collisions
		for other in pairs(others.notColliding) do
			-- collision just ended
			if collider.collidingWith[other] then
				exit[#exit + 1] = other
			end
		end

		collider.collidingWith = collections.copy(others.colliding)
		if next(enter) then
			collider.gameObject:collisionenter(collections.copy(enter))
		end
		if next(exit) then
			local noCollisionsLeft = not next(enter)
			collider.gameObject:collisionexit(collections.copy(exit), noCollisionsLeft)
		end
	end
end

--[[public]]

local GameScene = class.define(GameEntity, function(self, transform)

	self.gameObjects = {}
	self.globals = {}
	self.globals.drawables = {}
	self.globals.colliders = {}
	GameEntity.init(self, transform)
end)

function GameScene:loadSettings(settingsFile)

	self.settings = createSettingsTable(love.filesystem.load(settingsFile)())
end

function GameScene:load(src)
	--load objects and settings from a table or module

	local typeS = type(src)
	local source = ""
	local r

	if typeS == "string" then
		source = src
		-- load the module file and attempt to execute it
		r, src = pcall(love.filesystem.load(source))
		assert(r, "could not load " .. source)
	elseif typeS == "nil" then
		source = self.settings.firstScene
		r, src = pcall(love.filesystem.load(source))
		assert(r, "could not load " .. source)
	else
		assert(typeS == "table", "src must be file name, module name, or table")
		assert(src.gameObjects, "src.gameObjects is required")
		assert(src.settings, "src.settings is required")
	end

	self:init()
	self.source = source

	--scene settings (overrides settings.lua)
	self.settings = createSettingsTable(src.settings, self.settings)
	self:applySettings()

	--build game objects
	for i, object in ipairs(src.gameObjects) do
		buildObjectTree(self, object)
	end

end

function GameScene:applySettings()

	--window
	love.window.setMode(self.settings.window.width, self.settings.window.height)
	love.window.setTitle(self.settings.window.title or "Untitled")

	--graphics
	love.graphics.setBackgroundColor(self.settings.graphics.backgroundColor)

	--physics
	self.globals.gravity = geometry.Vector2(self.settings.physics.gravity)
end

function GameScene:addGameObject(gameObject)
	--add a GameObject to this GameScene (call this from gameObject constructor)

	assert(class.instanceof(gameObject, GameObject), "gameObject must be GameObject")

	gameObject.gameScene = self
	table.insert(self.gameObjects, gameObject)

	--print("added " .. gameObject.name .. " to scene at " .. gameObject.transform.position.x)

end

function GameScene:removeGameObject(gameObject, removeDescendants, destroy)

	local index = collections.index(self.gameObjects, gameObject)
	if index then
		table.remove(self.gameObjects, index)
	end

	if removeDescendants == true then
		for i, child in ipairs(gameObject.children) do
			self:removeGameObject(child, true, destroy)
		end
	-- if this object has no parent, its children must become children of the scene
	elseif not class.instanceof(gameObject.parent, GameObject) then
		for i, child in ipairs(gameObject.children) do
			self:addChild(child, false)
		end
	end

	if destroy then
		for k,v in pairs(gameObject) do
			gameObject[k] = nil
		end
	end
end

function GameScene:update(dt)
	--update all children (top-level game objects) of the scene

	if not self.paused then
		maintainTransform(self)
		maintainCollisions(self)
		self.base.update(self, dt, not self.finishedFirstUpdate)
		if not self.finishedFirstUpdate then
			self.finishedFirstUpdate = true
		end
	end
end

function GameScene:draw()

	local drawables = {}
	local indices = {}

	--collect all drawable objects into buckets -- each bucket maps to a different z-value
	--self.globals.drawables is an unordered set
	for object in pairs(self.globals.drawables) do
		-- if object:isDrawable() then
			local bucket = drawables[object.globalTransform.position.z]
			-- print(object.globalTransform.position.z)
			if bucket then
				bucket[#bucket+1] = object
			else
				drawables[object.globalTransform.position.z] = {object}
			end
		-- end
	end

	--sort the z-values (indices) in reverse order (so highest are drawn first)
	for index in pairs(drawables) do
		indices[#indices+1] = index
	end
	table.sort(indices, function(a,b) return a > b end)

	--draw
	for i, index in ipairs(indices) do
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
	Component = Component,
}
