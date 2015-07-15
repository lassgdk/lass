local lass = require("lass")
local class = require("lass.class")
local geometry = require("lass.geometry")
local collections = require("lass.collections")

local MouseClickHandler = class.define(lass.Component)

function MouseClickHandler:mousepressed(x, y, button, clickedOnSelf)

end

return MouseClickHandler