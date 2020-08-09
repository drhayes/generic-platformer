local Object = require 'lib.classic'
local lume = require 'lib.lume'

local DrawService = Object:extend()

local LAYERS = {
  backgroundColor = 25,
  farBackground = 50,
  background = 100,
  player = 200,
  default = 500,
  foreground = 1000,
  secretArea = 1200,
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
  eventBus:on('gobRemoved', self.onGobRemoved, self)
  eventBus:on('gobsCleared', self.onGobsCleared, self)
end

function DrawService:onGobAdded(gob)
  if gob.draw then
    table.insert(self.drawables, gob)
    table.sort(self.drawables, drawableCompare)
  end
end

function DrawService:onGobRemoved(gob)
  if gob.draw then
    lume.remove(self.drawables, gob)
  end
end

function DrawService:onGobsCleared()
  lume.clear(self.drawables)
end

local lg = love.graphics

function DrawService:draw(offsetX, offsetY, scale, alpha)
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  scale = scale or 1
  alpha = alpha or 1

  lg.push()
  lg.scale(self.windowFactor * scale)
  lg.translate(-offsetX, -offsetY)
  -- TODO: This ain't gonna work.
  lg.setColor(1, 1, 1, alpha)
  local drawables = self.drawables
  for i = 1, #drawables do
    local drawable = drawables[i]
    drawable:draw(offsetX, offsetY, scale, alpha)
  end
  lg.pop()
end


return DrawService
