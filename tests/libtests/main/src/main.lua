--entrypoint for the game - if main.lua doesn't exist, the game won't run.

local lass = require("lass")
local system = require("lass.system")

local scene = {}
local opts = system.getopt(arg, "scene")
local testModules = {
	"geometrytest",
	"classtest"
}

function love.load()

	math.randomseed(os.time())
	scene = lass.GameScene()
	scene:loadSettings("settings.lua")

	local loadedModules = {}
	for i, v in ipairs(testModules) do
		loadedModules[i] = require(v)
	end

	for i, loadedModule in ipairs(loadedModules) do

		print("---" .. testModules[i] .. "---")
		local failures = 0

		for j, testName in ipairs(loadedModule.tests) do

			local r, d = xpcall(loadedModule[testName], debug.traceback, scene)
			-- local r, d = pcall(loadedModule[testName], scene)

			if not r then
				print(testName .. " gave the following error:")

				--indent the error message
				print("    " .. d:gsub("\n", "\n    "))

				failures = failures + 1
			end
		end

		print("Testing complete. Assertion failures: " .. failures)
	end

	print("All tests complete")

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
