local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")
local Collider = require("lass.builtins.physics.Collider")

local SimpleRigidbody = class.define(lass.Component, function(self, arguments)

	arguments.airResistance = arguments.airResistance or 0
	arguments.velocity = geometry.Vector2(arguments.velocity)

	self.collisions = {}
	self.base.init(self, arguments)
end)

local function checkCollisions(gameObject, oldPositions, moveBy)

	local collider = gameObject:getComponent(Collider)
	if not (collider and collider.solid) then
		return {}
	end

	local directionOverlaps = {}
	local collisions = {}
	local others = {}

	-- we need to update the global transform for the collision detection to work immediately
	gameObject:maintainTransform()

	-- for i, layer in ipairs(collider.layersToCheck) do
	-- 	others[layer] = collections.copy(gameObject.gameScene.globals.colliders[layer])
	-- end

	for layerName, layer in pairs(collider.globals.colliders) do
		-- add everything from layersToCheck to possible collisions
		if collections.index(collider.layersToCheck, layerName) then
			others[layerName] = collections.copy(layer)
		-- add everything whose layersToCheck include this collider's layers
		else
			for i, o in ipairs(layer) do
				for j, layerName2 in ipairs(collider.layers) do
					if collections.index(o.layersToCheck, layerName2) then
						if others[layerName2] then
							others[layerName2][#others[layerName2]] = o
						else
							others[layerName2] = {o}
						end
						break
					end
				end
			end
		end
	end

	for layerName, layer in pairs(others) do
		for i, other in ipairs(layer) do

			if other ~= collider and other.solid then
				local r, data = collider:isCollidingWith(other, moveBy)

				if r then
					-- if we were already colliding with other, check if overlap distance has increased
					if (
						collider.collidingWith[other] and
						((
							collider.collidingWith[other].directionOverlap and
							data.directionOverlap and
							collider.collidingWith[other].directionOverlap < data.directionOverlap
						) or
						collider.collidingWith[other].shortestOverlap < data.shortestOverlap)
					) then
						gameObject.transform.position = oldPositions[gameObject]
						gameObject:maintainTransform()
						return false
					-- only add colliders that we weren't already colliding with, and have non-zero overlap
					elseif not collider.collidingWith[other] and data.shortestOverlap ~= 0 then
						-- debug.log(other.gameObject.name, d)
						collisions[#collisions + 1] = {other, collider}
						if data.directionOverlap then
							directionOverlaps[#directionOverlaps + 1] = data.directionOverlap
						end
					end
				end
			end
		end
	end

	for i, child in ipairs(gameObject.children) do
		local cols, overlaps = checkCollisions(child, oldPositions, moveBy)
		if cols then
			for j, col in ipairs(cols) do
				collisions[#collisions + j] = col
			end
			for j, over in ipairs(overlaps) do
				directionOverlaps[#directionOverlaps + j] = over
			end
		else
			gameObject.transform.position = oldPositions[gameObject]
			--reset transform of every descendant except the child and its descendants
			--(because they've already been reset)
			gameObject:maintainTransform(true, child)
			return false
		end
	end

	return collisions, directionOverlaps
end

local function gatherPositions(gameObject)

	local positions = {}
	positions[gameObject] = geometry.Vector3(gameObject.transform.position)

	for i, child in ipairs(gameObject.children) do
		for k,v in pairs(gatherPositions(child)) do
			positions[k] = v
		end
	end

	return positions
end

local function move(self, moveBy)

	local gameObject = self.gameObject
	local oldPositions = gatherPositions(gameObject)
	-- local newPosition

	-- if type(y) == "boolean" or y == nil then
	-- 	newPosition = geometry.Vector3(x) + gameObject.transform.position
	-- 	stopOnCollide = y
	-- else
	-- 	newPosition = geometry.Vector3(x, y, z) + gameObject.transform.position
	-- 	stopOnCollide = stopOnCollide or false
	-- end

	-- gameObject.transform.position = newPosition

	gameObject:moveGlobal(moveBy)
	local newPosition = gameObject.transform.position

	if
		oldPositions[gameObject].x == newPosition.x and
		oldPositions[gameObject].y == newPosition.y and
		oldPositions[gameObject].z == newPosition.z
	then
		return false
	end

	local collisions, directionOverlaps = checkCollisions(gameObject, oldPositions, moveBy)

	-- local collider = gameObject:getComponent(Collider)
	-- local directionOverlaps = {}

	-- if collider and collider.solid then
	-- 	local others = {}
	-- 	local collisions = {}

	-- 	-- we need to update the global transform for the collision detection to work immediately
	-- 	gameObject:maintainTransform(true)

	-- 	for i, layer in ipairs(collider.layersToCheck) do
	-- 		others[layer] = collections.copy(gameObject.gameScene.globals.colliders[layer])
	-- 	end

	-- 	for layerName, layer in pairs(others) do
	-- 		for i, other in ipairs(layer) do

	-- 			if other ~= collider and other.solid then
	-- 				local r, data = collider:isCollidingWith(other, moveBy)

	-- 				if r then
	-- 					-- if we were already colliding with other, check if overlap distance has increased
	-- 					if (
	-- 						collider.collidingWith[other] and
	-- 						collider.collidingWith[other].shortestOverlap < data.shortestOverlap
	-- 					) then
	-- 						gameObject.transform.position = oldPosition
	-- 						gameObject:maintainTransform(true)
	-- 						return false
	-- 					-- only add colliders that we weren't already colliding with, and have non-zero overlap
	-- 					elseif not collider.collidingWith[other] and data.shortestOverlap ~= 0 then
	-- 						-- debug.log(other.gameObject.name, d)
	-- 						collisions[#collisions + 1] = other
	-- 						if data.directionOverlap then
	-- 							directionOverlaps[#directionOverlaps + 1] = data.directionOverlap
	-- 						end
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end

	if not collisions then
		return false
	elseif #collisions < 1 then
		return true
	elseif #directionOverlaps == #collisions then
		--we want to pull back by the greatest overlap distance
		table.sort(directionOverlaps, function(a,b) return a > b end)
		local dist = directionOverlaps[1]

		if moveBy.x ~= 0 then
			gameObject:moveGlobal(-(math.sign(moveBy.x) * dist), 0)
		elseif moveBy.y ~= 0 then
			gameObject:moveGlobal(0, -(math.sign(moveBy.y) * dist))
		end

		gameObject:maintainTransform()
		return true, collisions
	end

	local backward = true
	local lastBackward = backward
	local skip = newPosition - oldPositions[gameObject]
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
		gameObject.transform.position = oldPositions[gameObject]
		gameObject:maintainTransform()
		return false
	end

	if moveBy.x ~= 0 then
		gameObject.transform.position.x = math.floor(gameObject.transform.position.x)
	elseif moveBy.y ~= 0 then
		gameObject.transform.position.y = math.floor(gameObject.transform.position.y)
	end

	while not done do
		if backward then
			-- gameObject:moveGlobal(-skip)
			gameObject:move(-skip)
		else
			-- gameObject:moveGlobal(skip)
			gameObject:move(skip)
		end

		gameObject:maintainTransform(true)

		lastBackward = backward
		for i, c in ipairs(collisions) do
			local r, d = c[1]:isCollidingWith(c[2])
			--if colliding...
			if r then
				backward = true
				break
			end

			--if not colliding, move forward next time
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

		-- even if collision overlaps aren't exactly 0, we can stop here if
		-- we're just moving the collider back and forth
		if maintainSkip and not backward and lastBackward then
			done = true
		end

		counter = counter + 1
	end

	return true, collisions
end

function SimpleRigidbody:update(dt)

	self.velocity = self.velocity - self.globals.gravity

----[[

	local breakAfterY = true
	for i, axis in ipairs({"x", "y", "x"}) do

		local moveBy = geometry.Vector2()
		moveBy[axis] = self.velocity[axis] * dt

		-- local r, col = self.gameObject:moveGlobal(moveBy, true)
		local r, col = move(self, moveBy)
		-- results[axis] = r

		-- if col then
		-- 	debug.log(i, axis, r, col[1], col[2])
		-- end

		if r == false or col then
			-- if collision happened during horizontal movement, try again after vertical movement
			if i == 1 then
				breakAfterY = false
			else
				self.velocity[axis] = 0
			end
		end

		-- even if not breakAfterY, there's no point in trying again if vertical movement was 0
		if i == 2 then
			if breakAfterY then
				break
			-- if we break before resetting velocity.x, it will continue to accelerate.
			-- plus, we know that if breakAfterY is false, a horizontal collision or standstill occurred
			elseif moveBy[axis] == 0 then
				self.velocity.x = 0
				break
			end
		end
	end
--]]
end

return SimpleRigidbody