--entrypoint for the game - if main.lua doesn't exist, the game won't run.
--automatically generated by lasspm

local lass = require("lass")
local system = require("lass.system")

local scene = {}
local opts = system.getopt(arg, "scene")

function love.load()

	math.randomseed(os.time())
	scene = lass.GameScene()
	scene:loadSettings("settings.lua")

	-- if opts.scene is nil, firstScene from settings.lua will be used
	debug.log("preload")
	scene:load(opts.scene)
	debug.log("postload")
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
