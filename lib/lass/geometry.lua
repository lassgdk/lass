local class = require("lass.class")

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

	assertOperandsHaveXandY(vector, nil, "nil")
	assert(type(scalar) == "number", "cannot multiply vector and " .. type(scalar))

	return Vector2(vector.x * scalar, vector.y * scalar)
end

function Vector2:__unm()
	return Vector2(-self.x, -self.y)
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

	angle = -angle
	if not useRadians then
		angle = (angle/180) * math.pi
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

	if self.x == 0 and self.y == 0 then
		--lua uses infinity as a stand-in for NaN
		return math.huge
	elseif self.x == 0 then
		if self.y > 0 then
			return 0.5 * math.pi * c
		else -- y < 0
			return 1.5 * math.pi * c
		end
	end

	--tangent = opposite / adjacent
	local ang =  math.atan(self.y / self.x)

	-- right now the angle doesn't tell us which quadrant the vector is in

	-- top-left quadrant should be between 90 and 180;
	-- bottom-left quadrant should be between 180 and 270
	if self.x < 0 then
		return (ang + math.pi) * c
	-- bottom-right quadrant should be between 270 and 0 (360)
	elseif self.y < 0 then
		return (ang + (2 * math.pi)) * c
	-- top-right quadrant should be unaltered
	else
		return ang * c
	end
end

function Vector2:dot(other)

	return self.x * other.x + self.y * other.y
end

function Vector2:project(direction)
	--project this vector onto a direction vector

	assertOperandsHaveXandY(self, direction)
	return (self:dot(direction) / Vector2.dot(direction, direction)) * direction
end

local function flattenedVector2Array(vectors)

	flattened = {}
	for i, vector in ipairs(vectors) do
		flattened[#flattened + 1] = vector.x
		flattened[#flattened + 1] = vector.y
	end
	return flattened
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

	if type(x) == "table" then
		z = x.z
	end

	self.z = z or 0
	Vector2.init(self, x, y)
end)

function Vector3.__add(a, b)

	assertOperandsHaveXandY(a, b)
	a, b = sanitizeOperandZAxis(a, b)
	return Vector3(a.x+b.x, a.y+b.y, a.z+b.z)
end

function Vector3.__sub(a, b)

	assertOperandsHaveXandY(a, b)
	a, b = sanitizeOperandZAxis(a, b)
	return Vector3(a.x-b.x, a.y-b.y, a.z-b.z)
end

function Vector3:__unm()
	return Vector3(-self.x, -self.y, -self.z)
end

function Vector3:__tostring()
	return string.format("{x=%.2f, y=%.2f, z=%.2f}", self.x, self.y, self.z)
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

	local vec = Vector3(Vector2.rotate(self, angle, useRadians))
	vec.z = self.z
	return vec
end

--[[
Transform
]]

local Transform = class.define(function(self, position, rotation, size)

	if position and (position.position or position.rotation or position.size) then
		size = position.size
		rotation = position.rotation
		position = position.position
	end

	self.position = Vector3(position)
	self.rotation = (rotation or 0) % 360
	if size then
		size.x = size.x or 1
		size.y = size.y or 1
		size.z = size.z or 1
		self.size = Vector3(size)
	else
		self.size = Vector3(1,1,1)
	end
end)

--[[
Shape
]]

--this is basically just an interface
local Shape = class.define()

--[[Circle]]

local Circle = class.define(Shape, function(self, radius, center)

	assert(type(radius) == "number", "radius must be number")
	assert(class.instanceof(center, Vector2) or center == nil, "center must be Vector2 or nil")

	self.radius = radius
	self.center = center or Vector2(0, 0)
end)

function Circle:area()
	return math.pi * self.radius^2
end

function Circle:circumference()
	return math.pi * self.radius * 2
end

function Circle:globalCenter(transform)
	return transform.position + self.center
end

function Circle:globalCircle(transform)
	--transform size.x is assumed to be the radius (eventually, we'll make an ellipse object)
	return Circle(self.radius * transform.size.x, self.center + transform.position)
end

function Circle:contains(vector)
	return (vector-self.center):magnitude() <= self.radius
end

--[[
Polygon
]]

--[[internal]]
local function intersectingPolygonAndOther(poly1, other, transform1, transform2)

	transform1 = transform1 or Transform()
	local gc = nil

	-- print(transform1.rotation)
	-- for i, v in ipairs(poly1:globalVertices(transform1)) do print(i,v) end

	local poly1Verts = poly1:globalVertices(transform1)
	local otherVerts = nil
	local otherType = class.instanceof(other, Vector2, Circle)
	if otherType == Vector2 then
		otherVerts = {other}
	elseif otherType == Circle then
		gc = other:globalCircle(transform2)
		--we will rotate the "vertices" (center and two outmost points) on each new axis
		otherVerts = {
			-- gc.center - Vector2(gc.radius, 0),
			gc.center,
			-- gc.center + Vector2(gc.radius, 0)
		}
	else
		otherVerts = other:globalVertices(transform2)
	end

	local minDistance = nil

	--check against every axis of both colliders
	--if collider is polygon, axis is normal of a side
	--if collider is circle, axis is the line between the closest polygon vertex and the circle center
	for icollider, collider in ipairs({poly1Verts, otherVerts}) do
		local len = #collider
		-- print("len", len)

		--if the 2nd collider has only one vertex, we've already checked it
		if otherType == Vector2 and icollider == 2 then
			return true
		end

		local normal = nil
		local minSm = nil
		local closest = nil

		--if this collider is a circle, we generate the "normal" here
		if icollider == 2 and otherType == Circle then

			-- naively find the point on the polygon that is closest to the circle
			-- TODO: find the point by using voronoi regions instead
			for i, vertex in ipairs(poly1Verts) do
				local sm = (vertex - other:globalCenter(transform2)):sqrMagnitude()
				if not minSm or sm <= minSm then
					minSm = sm
					closest = vertex
				end
			end
			normal = other:globalCenter(transform2) - closest
		end

		--if this is a polygon, we will check each side
		--if this is not a polygon, we will break at the end of the loop
		for i, vertex in ipairs(collider) do
			if icollider == 1 or otherType ~= Circle then
				normal = Vector2.rotate(collider[i%len + 1] - vertex, 90)
			end

			--the vector might be (0,0) if the 2nd collider is a circle,
			--and the 1st collider is touching its center
			if normal.x == 0 and normal.y == 0 then
				return true, {shortestOverlap=other.radius}
			end

			local normalAngle = normal:angle()

			local minPoint1 = nil
			local maxPoint1 = nil

			--project the first collider's vertices against the normal

			--we 'adjust' the projections by rotating them to y=0, to make them easier to sort
			for j, vertex2 in ipairs(poly1Verts) do
				local projected = vertex2:project(normal)
				local adjustedProjected = projected:rotate(normalAngle)

				if not minPoint1 then
					minPoint1 = adjustedProjected
				end

				if not maxPoint1 then
					maxPoint1 = adjustedProjected
				elseif adjustedProjected.x < minPoint1.x then
					minPoint1 = adjustedProjected
				elseif adjustedProjected.x > maxPoint1.x then
					maxPoint1 = adjustedProjected
				end
			end

			local minPoint2 = nil
			local maxPoint2 = nil

			--project the second collider's vertices against the normal
			for j, vertex2 in ipairs(otherVerts) do
				local projected = vertex2:project(normal)
				local adjustedProjected = projected:rotate(normalAngle)


				if otherType == Circle then
					minPoint2 = adjustedProjected - Vector2(gc.radius, 0)
					maxPoint2 = adjustedProjected + Vector2(gc.radius, 0)
				else
					if not minPoint2 then
						minPoint2 = adjustedProjected
					end

					if not maxPoint2 then
						maxPoint2 = adjustedProjected
					elseif adjustedProjected.x < minPoint2.x then
						minPoint2 = adjustedProjected
					elseif adjustedProjected.x > maxPoint2.x then
						maxPoint2 = adjustedProjected
					end
				end
			end
			-- print(minPoint1, maxPoint1, minPoint2, maxPoint2)

			local points = {{minPoint1,1}, {minPoint2,2}, {maxPoint1,1}, {maxPoint2,2}}
			table.sort(points, function(a,b) return a[1].x < b[1].x end)

			--if the first two sorted points are from the same collider, we've found a gap
			--(unless the min of one is exactly the max of the other)
			if points[1][2] == points[2][2] and points[2][1].x ~= points[3][1].x then
				return false
			end

			--calculate the lowest distance at which the shapes overlap
			if not minDistance then
				minDistance = points[3][1].x - points[2][1].x
			else
				local d = points[3][1].x - points[2][1].x
				if d < minDistance then
					minDistance = d
				end
			end

			--if this is a circle, there is only one "normal" to check, so we can break now
			if icollider == 2 and otherType == Circle then
				break
			end 
		end
	end

	--if no gaps have been found, there must be a collision
	return true, {shortestOverlap=minDistance}
end


--[[public]]

local Polygon = class.define(Shape, function(self, vertices)

	local originalVType = type(vertices[1])
	local newVerts = {}

	for i, v in ipairs(vertices) do
		--ensure type consistency
		if i ~= 1 then
			assert(type(v) == originalVType, "vertices must be all nums or all tables")
		end

		if originalVType == "number" and i % 2 == 1 then
			newVerts[math.floor(i/2) + 1] = Vector2(v, vertices[i+1])
		elseif originalVType == "table" then
			newVerts[i] = Vector2(v)
		end
	end
	vertices = newVerts

	self.vertices = vertices
end)

function Polygon:globalVertices(transform)

	local globalVertices = {}
	for i, vertex in ipairs(self.vertices) do
		globalVertices[i] = Vector2(vertex.x * transform.size.x, vertex.y * transform.size.y)
		globalVertices[i] = globalVertices[i]:rotate(transform.rotation) + transform.position
	end

	return globalVertices
end

function Polygon:globalPolygon(transform)

	return Polygon(self:globalVertices(transform))
end

function Polygon:contains(vector)
	return intersectingPolygonAndOther(self, vector)
end

function Polygon:isConvex()

end

--[[
Rectangle
]]

local Rectangle = class.define(Shape, function(self, width, height, origin)
	-- origin is assumed to be top left

	assert(type(width) == "number", "width must be number")
	assert(type(height) == "number", "height must be number")
	assert(class.instanceof(origin, Vector2) or origin == nil, "origin must be Vector2 or nil")

	self.width = width
	self.height = height
	self.origin = origin or Vector2(0, 0)
end)

function Rectangle:vertices()
	return {
		self.origin,
		self.origin + Vector2(self.width, 0),
		self.origin + Vector2(self.width, -self.height),
		self.origin + Vector2(0, -self.height)
	}
end

function Rectangle:globalVertices(transform, ignoreRotation)

	local globalVertices = {}
	for i, vertex in ipairs(self:vertices()) do
		globalVertices[i] = Vector2(vertex.x * transform.size.x, vertex.y * transform.size.y)
		if not ignoreRotation then
			globalVertices[i] = globalVertices[i]:rotate(transform.rotation) + transform.position
		end
	end

	return globalVertices
end

function Rectangle:globalRectangle(transform)

	local r = transform.rotation					--180
	local width = self.width * transform.size.x		--40 * 1
	local height = self.height * transform.size.y	--15 * 1
	local origin = Vector2(self.origin)				--0,0

	if r % 90 == 0 and r % 360 ~= 0 then
		local tmp

		-- rotate 180; bottom right becomes origin
		if r % 180 == 0 then
			origin = (origin + Vector2(self.width, -self.height)):rotate(r)	--0,0 +

		-- rotate 90 cw; bottom left becomes origin
		elseif r == 90 or r == -270 then
			origin = (origin + Vector2(0, -self.height)):rotate(r)
			tmp = width
			width = height
			height = tmp

		-- rotate 90 ccw; top right becomes origin
		else
			origin = (origin + Vector2(self.width, 0)):rotate(r)
			tmp = width
			width = height
			height = tmp
		end
	end

	origin.x = origin.x * transform.size.x + transform.position.x
	origin.y = origin.y * transform.size.y + transform.position.y

	-- if r ~= 0 then
	-- 	debug.log("=====")
	-- 	debug.log(self.width,self.height,self.origin)
	-- 	debug.log(width,height,origin)
	-- end
	return Rectangle(width, height, origin)
end

function Rectangle:toPolygon()
	return Polygon(self:vertices())
end

function Rectangle:contains(vector)
	return
		vector.x >= self.origin.x and
		vector.x <= self.origin.x + self.width and
		vector.y <= self.origin.y and
		vector.y >= self.origin.y - self.height
end

--[[
intersection functions
]]

--[[internal]]

local function intersectingCircles(cir1, cir2, transform1, transform2)

	local distance = Vector2(cir1:globalCenter(transform1) - cir2:globalCenter(transform2)):magnitude()
	local intersecting = distance <= cir1.radius + cir2.radius

	if not intersecting then
		distance = nil
	end

	return intersecting, {shortestOverlap = distance}
end

local function intersectingFixedRectangles(rect1, rect2, transform1, transform2, direction)
	--checks intersection of two rectangles, where rotation is assumed to be 0

	local rect1 = rect1:globalRectangle(transform1)
	local rect2 = rect2:globalRectangle(transform2)

	-- return
	-- 	--is 1's left edge on, or to the left of, 2's right edge?
	-- 	rect1.origin.x <= rect2.origin.x + rect2.width and
	-- 	--is 1's right edge on, or to the right of, 2's left edge?
	-- 	rect1.origin.x + rect1.width >= rect2.origin.x and
	-- 	--is 1's top edge on or above 2's bottom edge?
	-- 	rect1.origin.y >= rect2.origin.y - rect2.height and
	-- 	--is 1's bottom edge on or below 2's top edge?
	-- 	rect1.origin.y - rect1.height <= rect2.origin.y

	local overlaps = {
		--is 1's left edge on, or to the left of, 2's right edge?
		rect1.origin.x - (rect2.origin.x + rect2.width),
		--is 1's right edge on, or to the right of, 2's left edge?
		rect2.origin.x - (rect1.origin.x + rect1.width),
		--is 1's top edge on or above 2's bottom edge?
		(rect2.origin.y - rect2.height) - rect1.origin.y,
		--is 1's bottom edge on or below 2's top edge?
		(rect1.origin.y - rect1.height) - rect2.origin.y
	}
	local minDistance = nil

	for i, o in ipairs(overlaps) do
		if o > 0 then
			return false
		elseif not minDistance then
			minDistance = math.abs(o)
		elseif math.abs(o) < minDistance then
			minDistance = math.abs(o)
		end
	end

	local data = {shortestOverlap=minDistance}

	--TODO: deal with diagonal directions

	if direction then
		--1 approaching from the left
		if direction.x > 0 then
			data.directionOverlap = overlaps[2]
		--1 approaching from the right
		elseif direction.x < 0 then
			data.directionOverlap = overlaps[1]
		--1 approaching from the top
		elseif direction.y < 0 then
			data.directionOverlap = overlaps[4]
		--1 approaching from the bottom
		elseif direction.y > 0 then
			data.directionOverlap = overlaps[3]
		end

		data.directionOverlap = math.abs(data.directionOverlap)
	end

	return true, data
end

-- local function intersectingFixedRectangleAndCircle(rect, cir, transform1, transform2)

-- 	rect = rect:globalRectangle(transform1)
-- 	cir = cir:globalCircle(transform2)

-- 	--is one of the rectangle's vertices inside the circle?
-- 	for i, vertex in ipairs(rect:vertices()) do
-- 		if cir:contains(vertex) then
-- 			return true
-- 		end
-- 	end

-- 	--or is the circle's center inside the rectangle?
-- 	return rect:contains(cir.center)
-- end


local function guaranteeOrder(firstValue, ...)

	local arg = {...}

	if arg[1] ~= firstValue then
		local newarg = {}
		for i = 1, #arg, 2 do
			newarg[i] = arg[i+1]
			newarg[i+1] = arg[i]
		end
		return unpack(newarg)
	else
		return ...
	end
end

--[[public]]

local function intersecting(fig1, fig2, transform1, transform2, ignoreRotation1, ignoreRotation2, direction)

	assert(
		class.instanceof(fig1, Shape, Vector2) and class.instanceof(fig2, Shape, Vector2),
		"both figures must be instances of Shape or Vector2"
	)

	transform1 = Transform(transform1)
	transform2 = Transform(transform2)
	local fig1Type = class.instanceof(fig1, Vector2, Rectangle, Circle, Polygon)
	local fig2Type = class.instanceof(fig2, Vector2, Rectangle, Circle, Polygon)

	--collision between two points
	if fig1Type == Vector2 and fig2Type == Vector2 then
		fig1 = Vector3(fig1) + transform1.position
		fig2 = Vector3(fig2) + transform2.position
		return fig1.x == fig2.x and fig1.y == fig2.y and fig1.z == fig2.z
	end

	--if not ignoreRotation and rotation not divisible by 90, cast any rectangles to polygons
	if ignoreRotation1 then
		transform1.rotation = 0 
	elseif fig1Type == Rectangle and transform1.rotation % 90 ~= 0 then
		fig1, fig1Type = fig1:toPolygon(), Polygon
	end
	if ignoreRotation2 then
		transform2.rotation = 0 
	elseif fig2Type == Rectangle and transform2.rotation % 90 ~= 0 then
		fig2, fig2Type = fig2:toPolygon(), Polygon
	end

	--collision between two fixed rectangles
	if fig1Type == Rectangle and fig2Type == Rectangle then
		return intersectingFixedRectangles(fig1, fig2, transform1, transform2, direction)

	--collision between a fixed rectangle and something else
	elseif fig1Type == Rectangle or fig2Type == Rectangle then
		local _, otherType, rec, other, transformRec, transformOther, ignoreRotationRec, ignoreRotationOther =
			guaranteeOrder(
				Rectangle,
				fig1Type, fig2Type, fig1, fig2, transform1, transform2, ignoreRotation1, ignoreRotation2
			)

		--collision between a fixed rectangle and a vector
		if otherType == Vector2 then
			return rec:globalRectangle(transformRec):contains(other + transformOther.position)
		--collision between a fixed rectangle and a circle
		-- elseif otherType == Circle then
			-- return intersectingFixedRectangleAndCircle(rec, other, transformRec, transformOther)
		--collision between a fixed rectangle and a polygon
		elseif otherType == Polygon or otherType == Circle then
			return intersectingPolygonAndOther(rec:toPolygon(), other, transformRec, transformOther)
		end

	--collision between two circles
	elseif fig1Type == Circle and fig2Type == Circle then
		return intersectingCircles(fig1, fig2, transform1, transform2)

	--collision between a circle and either a vector or a polygon
	elseif fig1Type == Circle or fig2Type == Circle then

		local _, otherType, cir, other, transformCir, transformOther, __, ignoreRotationOther =
			guaranteeOrder(
				Circle,
				fig1Type, fig2Type, fig1, fig2, transform1, transform2, ignoreRotation1, ignoreRotation2
			)

		--collision between a circle and a vector
		if otherType == Vector2 then
			return cir:globalCircle(transformCir):contains(other)
		--collision between a circle and a polygon
		else
			cir = Circle(cir.radius, cir.center)
			return intersectingPolygonAndOther(other, cir, transformOther, transformCir)
		end

	--collision between a polygon and either a polygon or a vector
	elseif fig1Type == Polygon or fig2Type == Polygon then
		--we've already accounted for rotation by now
		local _, otherType, pol, other, transformPol, transformOther =
			guaranteeOrder(
				Polygon, fig1Type, fig2Type, fig1, fig2, transform1, transform2
			)

		return intersectingPolygonAndOther(pol, other, transformPol, transformOther)
	end
end

--[[
graph functions
]]

local functions = {}

function functions.sine(x)
	return math.sin(x)
end

function functions.pulse(x, pulseWidth)

	pulseWidth = pulseWidth or .5
	if (x % (math.pi*2)) / (math.pi*2) < pulseWidth then
		return 1
	else
		return -1
	end
end

functions["y=x"] = function(x)
	return x
end

return {
	Transform = Transform,
	Vector2 = Vector2,
	Vector3 = Vector3,
	Shape = Shape,
	Polygon = Polygon,
	Circle = Circle,
	Rectangle = Rectangle,
	intersecting = intersecting,
	degreesToRadians = function(d) return (d/180) * math.pi end,
	flattenedVector2Array = flattenedVector2Array,
	functions = functions
}
