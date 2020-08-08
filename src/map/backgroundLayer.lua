local Object = require 'lib.classic'

local BackgroundLayer = Object:extend()

function BackgroundLayer:new(r, g, b, a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
  self.layer = 'background'
end

function BackgroundLayer:initialize() end

function BackgroundLayer:update(dt) end

local lg = love.graphics

function BackgroundLayer:draw()
  lg.push()
  lg.setColor(self.r, self.g, self.b, self.a)
  lg.rectangle('fill', 0, 0, 1600, 1600)
  lg.pop()
end

return BackgroundLayer
