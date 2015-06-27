local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")

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

	self:load(prefabs)	
end

function TileMap:load(prefabs)

	local ySign = 1
	if self.gameObject.gameScene.settings.graphics.invertYAxis then
		ySign = -1
	end

	if #self.gameObject.children > 0 then
		self:clear()
	end

	for i, row in ipairs(self.map) do
		for j, tile in ipairs(row) do
			if tile ~= 0 then

				local p = collections.deepcopy(prefabs[tile])
				p.transform.position = {
					x = (j-1) * self.tileSize.x,
					y = (i-1) * self.tileSize.y * ySign,
				}

				local g = lass.GameObject.fromPrefab(self.gameObject.gameScene, p)
				self.gameObject:addChild(g)
				g.name = g.name .. " " .. tostring(j) .. " " .. tostring(i)
			
				-- g:moveTo((j-1) * self.tileSize.x, (i-1) * self.tileSize.y * ySign, g.transform.position.z)
			end
		end
	end
end

function TileMap:clear()

	for i, child in ipairs(self.gameObject.children) do
		-- remove and destroy all children of the tile map
		self.gameScene:removeGameObject(child, false, true)
	end
end

return TileMap