local Object = require 'lib.classic'

local Gamestate = Object:extend()

function Gamestate:new(eventBus)
  self.eventBus = eventBus
end

function Gamestate:enter() end
function Gamestate:update(dt) end
function Gamestate:draw() end
function Gamestate:leave() end


return Gamestate
