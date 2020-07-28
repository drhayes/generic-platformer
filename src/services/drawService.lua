local Object = require 'lib.classic'

local DrawService = Object:extend()

function DrawService:new(eventBus, windowFactor)
  self.windowFactor = windowFactor
  self.drawables = {}

  eventBus:on('gobAdded', self.onGobAdded, self)
end

function DrawService:onGobAdded(gob)
  if gob.draw then
    table.insert(self.drawables, gob)
  end
end

local lg = love.graphics

function DrawService:draw()
  lg.push()
  lg.scale(self.windowFactor)
  local drawables = self.drawables
  for i = 1, #drawables do
    local drawable = drawables[i]
    drawable:draw()
  end
  lg.pop()
end


return DrawService
