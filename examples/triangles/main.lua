local lass = require("lass")

local scene = {}

function love.load()
	scene = lass.GameScene()
	scene:load("mainscene")
end

for i, f in ipairs({
	"draw",
	"update",
	"errhand",
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

-- love.draw
--[[
"errhand",
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
"visible",
]]