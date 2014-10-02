local require("lass")
local require("lass.class")

Collider = class(Component, function(self, properties)

	assert(properties.hitbox.width and properties.hitbox.height, 
		"must specify hitbox.width and hitbox.height")

	properties.hitbox.x = properties.hitbox.x or 0
	properties.hitbox.y = properties.hitbox.y or 0

	Component.init(self, properties)
end)

-- function update(dt)
-- 	self.hitbox.
-- end

function Collider:getGlobalHitbox()

	local hitbox = {}
	for k,v in pairs(self.hitbox) do
		--hitbox position relative to global position
		if k == "x" or k == "y" then
			hitbox[k] = v + self[k]
		else
			hitbox[k] = v
		end
	end
	return hitbox
end

function Collider:checkCollision(target)
	local hitbox = self:getGlobalHitbox()
	local targetHitbox = target:getGlobalHitbox()

	return targetHitbox.x <= hitbox.x+hitbox.width,-- and
		targetHitbox.x >= hitbox.x,-- and
		targetHitbox.y >= hitbox.y,-- and
		targetHitbox.y <= hitbox.y+hitbox.height
end

function Collider:move(x, y, stopOnCollision)
	if stopOnCollision == nil then
		stopOnCollision = true
	end

	self.x = self.x - x
	self.y = self.y + y

end

return Collider
