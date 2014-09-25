require("lass")

scene = {}

function love.load()
	love.window.setMode(800, 600)
	love.graphics.setBackgroundColor(255,255,255)

	scene = GameScene()
	scene:loadSceneFile("mainscene")

end

function love.draw()
	love.graphics.setColor(0,0,0)
	scene:draw()
end

function love.update(dt)
	scene:update(dt)
end
