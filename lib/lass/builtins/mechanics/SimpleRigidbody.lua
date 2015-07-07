local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")
local Collider = require("lass.builtins.collision.Collider")

local SimpleRigidbody = class.define(lass.Component, function(self, arguments)

	arguments.airResistance = arguments.airResistance or 0
	arguments.velocity = geometry.Vector2(arguments.velocity)

	self.collisions = {}
	self.base.init(self, arguments)
end)

local function move(self, moveBy)

	local oldPosition = geometry.Vector3(self.transform.position)
	-- local newPosition

	-- if type(y) == "boolean" or y == nil then
	-- 	newPosition = geometry.Vector3(x) + self.transform.position
	-- 	stopOnCollide = y
	-- else
	-- 	newPosition = geometry.Vector3(x, y, z) + self.transform.position
	-- 	stopOnCollide = stopOnCollide or false
	-- end

	-- self.transform.position = newPosition

	self:moveGlobal(moveBy)
	local newPosition = self.transform.position

	if
		oldPosition.x == newPosition.x and
		oldPosition.y == newPosition.y and
		oldPosition.z == newPosition.z
	then
		return false
	end

	local collider = self:getComponent(Collider)
	if collider and collider.solid then
		local others = {}
		local collisions = {}

		-- we need to update the global transform for the collision detection to work immediately
		self:maintainTransform()

		for i, layer in ipairs(collider.layersToCheck) do
			others[layer] = collections.copy(self.gameScene.globals.colliders[layer])
		end

		for layerName, layer in pairs(others) do
			for i, other in ipairs(layer) do

				if other ~= collider and other.solid then
					local r, d = collider:isCollidingWith(other)

					if r then
						-- if we were already colliding with other, check if overlap distance has increased
						if
							collider.collidingWith[other] and
							collider.collidingWith[other] < d
							-- and d > 0.0001
						then
							debug.log(d, moveBy)
							self.transform.position = oldPosition
							self:maintainTransform()

							return false
						-- only add colliders that we weren't already colliding with, and have non-zero overlap
						elseif not collider.collidingWith[other] and d ~= 0 then
							-- debug.log(other.gameObject.name, d)
							collisions[#collisions + 1] = other
						end
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
			self:maintainTransform()
			return false
		end

		if moveBy.x ~= 0 then
			self.transform.position.x = math.floor(self.transform.position.x)
		elseif moveBy.y ~= 0 then
			self.transform.position.y = math.floor(self.transform.position.y)
		end

		while not done do
			if backward then
				self.transform.position = self.transform.position - skip
			else
				self.transform.position = self.transform.position + skip
			end

			self:maintainTransform()

			lastBackward = backward
			for i,c in ipairs(collisions) do
				local r, d = collider:isCollidingWith(c)

				--we are done if at least one collision has an overlap of 0,
				--and the others are colliding at 0 or not at all

				--if colliding...
				if r then
					--...and if overlap is 0, stop here
					-- if d == 0 then
					-- 	done = done
					-- --else, move backward next time
					-- else
						backward = true
						break
					-- end
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
end

function SimpleRigidbody:update(dt)

	self.velocity = self.velocity - self.globals.gravity

----[[

	local breakAfterY = true
	for i, axis in ipairs({"x", "y", "x"}) do

		local moveBy = geometry.Vector2()
		moveBy[axis] = self.velocity[axis] * dt

		-- local r, col = self.gameObject:moveGlobal(moveBy, true)
		local r, col = move(self.gameObject, moveBy)
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