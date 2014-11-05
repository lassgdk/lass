local lass = require("lass")

local scene = {}

function love.load()
	scene = lass.GameScene()
	scene:load("mainscene")
end

for i, f in ipairs({"draw", "update", "mousepressed"}) do
	love[f] = function(...)
		scene[f](scene, ...)
	end
end
