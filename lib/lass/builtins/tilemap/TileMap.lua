local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")
local csv = require("lass.collections.csv")

local TileMap = class.define(lass.Component, function(self, arguments)

	arguments.map = arguments.map or {}
	arguments.tileSize = geometry.Vector2(arguments.tileSize)
	arguments.tiles = arguments.tiles or {}
	self.base.init(self, arguments)
end)

function TileMap:awake()

	local prefabs = {}
	for k,v in pairs(self.tiles) do
		if k ~= 0 then
			if type(v) == "string" then
				prefabs[k] = love.filesystem.load(v)()
			else
				prefabs[k] = v
			end

			if not prefabs[k].transform then
				prefabs[k].transform = {}
			end
		end
	end

	self.prefabs = prefabs
	self:load(self.mapFile)	
end

local function imageDataToTileMap(self, imageData)

	local palette = {}
	local map = {}

	for i, color in ipairs(self.mapFilePalette) do

		-- convert the list of rgb components to a number value
		-- e.g., {255, 0, 0} => 0xff0000
		-- then, store it as a key to its corresponding tile value
		palette[(color[1] * 2^16) + (color[2] * 2^8) + color[3]] = i
	end

	for row = 1, imageData:getHeight() do
		map[row] = {}
		for column = 1, imageData:getWidth() do
			local r, g, b = imageData:getPixel(column-1, row-1)
			local tile = palette[(r * 2^16) + (g * 2^8) + b]

			map[row][column] = tile or 0
		end
	end

	return map
end

function TileMap:load(filename)

	local ySign = self.globals.ySign

	--load tilemap from csv or image file, if one is specified

	self.mapFile = filename or self.mapFile

	if self.mapFile then
		self.map = {}

		if self.mapFilePalette then
			local image = love.graphics.newImage(self.mapFile)
			assert(not image:isCompressed(), "compressed image format not supported by TileMap")

			self.map = imageDataToTileMap(self, image:getData())
		else
			local data, msg = csv.open(self.mapFile)
			assert(data, msg)

			local i = 1
			for line in data:lines() do
				self.map[i] = {}

				for j, v in ipairs(line) do
					self.map[i][j] = tonumber(v)
				end

				i = i + 1
			end
		end
	end

	-- clear any existing tiles

	if #self.gameObject.children > 0 then
		self:clear()
	end

	-- instantiate tiles

	for i, row in ipairs(self.map) do
		for j, tile in ipairs(row) do
			if tile ~= 0 then

				local p = collections.deepcopy(self.prefabs[tile])

				if p then
					p.transform.position = {
						x = (j-1) * self.tileSize.x,
						y = (i-1) * self.tileSize.y * ySign,
					}

					local g = lass.GameObject.fromPrefab(self.gameObject.gameScene, p)
					self.gameObject:addChild(g)
					g.name = g.name .. " " .. tostring(j) .. " " .. tostring(i)
				end
			end
		end
	end
end

function TileMap:clear()

	for i, child in ipairs(collections.copy(self.gameObject.children)) do
		-- remove and destroy all children of the tile map
		self.gameScene:removeGameObject(child)
	end
end

return TileMap
