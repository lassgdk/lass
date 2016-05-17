--entrypoint for the game - if main.lua doesn't exist, the game won't run.

local lass = require("lass")
local system = require("lass.system")
local turtlemode = require("turtlemode")

local scene = lass.GameScene()
local opts = system.getopt(arg, "scene")

function love.load()

	math.randomseed(os.time())
	turtlemode.run()

	love.event.quit()
end

function love.errhand(msg)

	print(debug.traceback("Error: " .. tostring(msg), 3):gsub("\n[^\n]+$", ""))

	-- game should automatically quit after function return
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
	if f == "resize" then
		love[f] = function(...)
			scene.windowresize(scene, ...)
		end
	else
		love[f] = function(...)
			scene[f](scene, ...)
		end
	end
end
