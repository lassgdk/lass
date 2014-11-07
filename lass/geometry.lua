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

	if not useRadians then
		angle = -(angle/180) * math.pi
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

	--tangent = opposite / adjacent
	return math.atan(self.y / self.x) * c
end

function Vector2:dot(other)

	return self.x * other.x + self.y * other.y
end

function Vector2:project(direction)
	--project this vector onto a direction vector

	assertOperandsHaveXandY(self, direction)
	return (self:dot(direction) / Vector2.dot(direction, direction)) * direction
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

	Vector2.init(self, x, y)

	if type(x) == "table" then
		z = x.z
	end

	self.z = z or 0
end)

function Vector3.__add(a, b)

	assertOperandsHaveXandY(a, b)
	a, b = sanitizeOperandZAxis(a, b)
	return Vector3(a.x+b.x, a.y+b.y, a.z+b.z)
end

function Vector3.__sub(a, b)

	assertOperandsHaveXandY(a, b)
	a, b = sanitizeOperandZAxis(a, b)
	return Vector3(a.x+b.x, a.y+b.y, a.z+b.z)
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

	local vec = Vector2.rotate(self, angle, useRadians)
	vec.z = self.z
	return vec
end

return {
	Vector2 = Vector2,
	Vector3 = Vector3,
}
