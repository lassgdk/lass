local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local Collider = require("lass.builtins.physics.Collider")

local Rigidbody = class.define(lass.Component, function(self, arguments)

	arguments.velocity = geometry.Vector2(arguments.velocity)
	arguments.body = love.physics.newBody(self.globals.physicsWorld, 0, 0, "dynamic")

	self.base.init(self, arguments)
end)

local function shapeToPhysicsShape(self, shape, physicsShape, oldTransform)
	-- create or modify a physics shape using a geometry.Shape

	-- only Circle physics shapes can be modified, which makes this function's signature
	-- somewhat complicated:

	-- if physicsShape is not specified, return a new physics shape.
	-- if shape and physicsShape are not the same shape type, return a new physics shape.
	-- if shape and physicsShape are circles, modify physicsShape and return nil.
	-- if shape and physicsShape are polygons, and self.globalTransform == oldTransform,
	-- do nothing and return nil.
	-- if shape and physicsShape are polygons, and self.globalTransform ~= oldTransform,
	-- return a new physics shape.

	-- all of this is to say: if you specify physicsShape and this function returns a new
	-- physics shape, you should destroy the old shape and replace it with the new one.

	local transform = geometry.Transform(self.gameObject.globalTransform)

	--we want the global size and rotation of the shape, but not the global position
	transform.position = geometry.Vector3(0,0,0)

	if shape.class == geometry.Rectangle or shape.class == geometry.Polygon then

		if physicsShape and oldTransform then

			-- we can't directly edit the vertices of a PolygonShape.
			-- if we have a reason to change them, create a new PolygonShape.
			-- else, return nothing
			if
				oldTransform.r ~= transform.r or
				oldTransform.x ~= transform.x or
				oldTransform.y ~= transform.y or
				not physicsShape:typeOf("PolygonShape")
			then
				local verts = shape:globalVertices(transform)
				for i, vert in ipairs(verts) do
					vert.x = vert.x / self.globals.pixelsPerMeter
					vert.y = vert.y / self.globals.pixelsPerMeter
				end
				return love.physics.newPolygonShape(unpack(geometry.flattenedVector2Array(verts)))
			end
		else

			local verts = shape:globalVertices(transform)
			for i, vert in ipairs(verts) do
				vert.x = vert.x / self.globals.pixelsPerMeter
				vert.y = vert.y / self.globals.pixelsPerMeter
			end
			return love.physics.newPolygonShape(unpack(geometry.flattenedVector2Array(verts)))
		end

	elseif shape.class == geometry.Circle then
		local cir = shape:globalCircle(transform)

		-- thankfully, we can directly edit the radius and center of a CircleShape
		if physicsShape and physicsShape:typeOf("CircleShape") then
			physicsShape:setRadius(cir.radius)
			physicsShape:setPoint(cir.position.x, cir.position.y)
		else
			return love.physics.newCircleShape(cir.position.x, cir.position.y, cir.radius)
		end
	end
end

function Rigidbody.__get.velocity(self)

	local x, y = self.body:getLinearVelocity()
	return geometry.Vector2(x, y) * self.globals.pixelsPerMeter
end

function Rigidbody.__set.velocity(self, ...)

	self.body:setLinearVelocity(geometry.Vector2(...) / self.globals.pixels)
end

function Rigidbody:awake()

	local transform = self.gameObject.globalTransform
	self.body:setPosition(
		transform.position.x/self.globals.pixelsPerMeter,
		transform.position.y/self.globals.pixelsPerMeter
	)

	local colliders = self.gameObject:getComponents(Collider)

	for i, collider in ipairs(colliders) do
		love.physics.newFixture(self.body, shapeToPhysicsShape(self, collider.shape), 1)
	end

end

function Rigidbody:update()


end

return Rigidbody
