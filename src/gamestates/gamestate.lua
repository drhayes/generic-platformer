local Object = require 'lib.classic'

local Gamestate = Object:extend()

function Gamestate:new(registry, eventBus)
  self.registry = registry
  self.eventBus = eventBus
end

function Gamestate:enter() end
function Gamestate:update(dt) end
function Gamestate:draw() end
function Gamestate:leave() end

function Gamestate:subscribe(event, handler)
  self.eventBus:on(event, handler, self)
end


return Gamestate
