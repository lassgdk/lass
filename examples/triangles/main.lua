lass = require("lass")

scene = {}

function love.load()
	-- love.window.setMode(800, 600)
	-- love.graphics.setBackgroundColor(255,255,255)

	scene = lass.GameScene()
	scene:load("mainscene")
end

function love.draw()
	scene:draw()
end

function love.update(dt)
	scene:update(dt)
end
