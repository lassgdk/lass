local require("lass")
local require("lass.class")

Collider = class(Component, function(self, properties)

	if properties.vertices then
		for i, v in ipairs(properties.vertices) do
			if v then
				--
			end
		end
	else
		properties.vertices = {{x=0,y=0}}
	end
	Component.init(self, properties)
end)

-- function update(dt)
-- 	self.hitbox.
-- end

return Collider
