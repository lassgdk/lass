lass = require("lass")

scene = {}

function love.load()
	scene = lass.GameScene()
	scene:load("mainscene")
end

function love.draw()
	scene:draw()
end

function love.update(dt)
	scene:update(dt)
end
