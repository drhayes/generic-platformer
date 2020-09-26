local Control = require 'ui.control'
local Colorizable = require 'ui.colorizable'

local Label = Control:extend()
Label:implement(Colorizable)

local lg = love.graphics

function Label:new(font, text, hAlign, vAlign, x, y, w, h)
  self.font = font
  h = h or font:getHeight() + 2
  self:initColor()
  Label.super.new(self, x, y, w, h)
  self.hAlign = hAlign or 'left'
  self.vAlign = vAlign or 'top'
  self:updateText(text)
end

function Label:updateText(text)
  text = text or self.text
  self.text = text
  local font = self.font
  local fontHeight = font:getHeight()
  local tx, ty = 0, 0
  local textWidth = font:getWidth(text)
  if self.hAlign == 'right' then
    tx = tx + self.w - textWidth
  elseif self.hAlign == 'center' then
    tx = tx + self.w / 2 - textWidth / 2
  end
  if self.vAlign == 'bottom' then
    ty = ty + self.h - fontHeight
  elseif self.vAlign == 'middle' then
    ty = ty + self.h / 2 - fontHeight / 2
  end
  -- Set our text width based on whatever our new text is here.
  self.textWidth = tx + textWidth
  self.tx, self.ty = tx, ty
end

function Label:updateLayout()
  Label.super.updateLayout(self)
  self:updateText()
end

function Label:draw(ox, oy, alpha)
  ox, oy, alpha = ox or 0, oy or 0, alpha or 1
  local adjustedAlpha = alpha * self.alpha * self.color.a
  local dx, dy = ox + self.x + self.tx, oy + self.y + self.ty
  lg.push()
  self:setColor(adjustedAlpha)
  lg.setFont(self.font)
  lg.print(self.text, dx, dy)
  if self.isBold then
    lg.print(self.text, dx + 0.5, dy)
  end
  lg.pop()
end

function Label:__tostring()
  return 'Label'
end

return Label
