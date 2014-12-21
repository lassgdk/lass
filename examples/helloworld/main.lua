--entrypoint for the game - if main.lua doesn't exist, the game won't run.
--TODO: have lass automatically generate this file

local lass = require("lass")

local scene = {}

function love.load()
	scene = lass.GameScene()
	scene:load("mainscene")
end

function love.resize(...)
	scene:windowresize(...)
end

for i, f in ipairs({
	"draw",
	"update",
	"focus",
	"keypressed",
	"keyreleased",
	"mousefocus",
	"mousepressed",
	"mousereleased",
	"quit",
	"resize",
	"textinput",
	"threaderror",
	"visible"
}) do
	love[f] = function(...)
		scene[f](scene, ...)
	end
end