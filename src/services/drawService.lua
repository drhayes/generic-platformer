local Object = require 'lib.classic'

local DrawService = Object:extend()

local LAYERS = {
  background = 100,
  player = 200,
  default = 500,
  foreground = 1000,
}

local function drawableCompare(a, b)
  local aLayer = a.layer or 'default'
  local bLayer = b.layer or 'default'
  return LAYERS[aLayer] < LAYERS[bLayer]
end

function DrawService:new(eventBus, windowFactor)
  self.windowFactor = windowFactor
  self.drawables = {}

  eventBus:on('gobAdded', self.onGobAdded, self)
end

function DrawService:onGobAdded(gob)
  if gob.draw then
    table.insert(self.drawables, gob)
    table.sort(self.drawables, drawableCompare)
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
