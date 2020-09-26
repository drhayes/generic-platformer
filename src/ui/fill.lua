local Control = require 'ui.control'
local Colorizable = require 'ui.colorizable'
local HasFocusColor = require 'ui.hasFocusColor'

-- Ink.
local DEFAULT_FILL = {
  b = 0.14509803921569,
  g = 0.07843137254902,
  r = 0.094117647058824,
}

local Fill = Control:extend()
Fill:implement(Colorizable)
Fill:implement(HasFocusColor)

local lg = love.graphics

function Fill:new(x, y, w, h)
  Fill.super.new(self, x, y, w, h)
  self.baseColor = DEFAULT_FILL
  self:initColor(self.baseColor)
  self:initFocusColor()
  self.color.a = 1
  self:updateLayout()
end

function Fill:updateLayout()
  local w, h = self.w, self.h
  local fillCanvas  = lg.newCanvas(w, h)
  lg.setCanvas(fillCanvas)
  lg.setColor(1, 1, 1, 1)
  lg.rectangle('fill', 0, 0, w, h)
  lg.setCanvas()
  self.fillCanvas = fillCanvas
end

function Fill:update(dt)
  if self.isFocused then
    self:updateFocusColor(dt)
  else
    self:updateColor(self.baseColor)
  end
end

function Fill:draw(ox, oy, alpha)
  local dx, dy = ox + self.x, oy + self.y
  local adjustedAlpha = self.alpha * alpha
  lg.push()
  lg.setBlendMode('alpha')
  self:setColor(adjustedAlpha)
  lg.draw(self.fillCanvas, dx, dy)
  lg.pop()
end

return Fill
