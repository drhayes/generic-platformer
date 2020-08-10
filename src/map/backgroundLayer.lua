local GameObject = require 'gobs.gameObject'

local BackgroundLayer = GameObject:extend()

function BackgroundLayer:new(r, g, b, a)
  BackgroundLayer.super.new(self, 0, 0)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
  self.layer = 'backgroundColor'
end

function BackgroundLayer:initialize() end

local lg = love.graphics

function BackgroundLayer:draw()
  BackgroundLayer.super.draw(self)
  lg.push()
  lg.setColor(self.r, self.g, self.b, self.a)
  -- lg.rectangle('fill', 0, 0, 1600, 1600)
  lg.pop()
end

function BackgroundLayer:__tostring()
  return 'BackgroundLayer'
end

return BackgroundLayer
