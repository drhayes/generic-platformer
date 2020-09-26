local Control = require 'core.ui.control'
local Fill = require 'core.ui.fill'
local palette = require 'core.palette'

local Panel = Control:extend()

function Panel:new(x, y, w, h)
  x, y, w, h = x or 0, y or 0, w or 16, h or 16
  Panel.super.new(self, x, y, w, h)
  self.fill = Fill()
  self:updateFillAlpha(0.8)
end

function Panel:updateLayout()
  Panel.super.updateLayout(self)
  local fill = self.fill
  if not fill then return end
  fill.x, fill.y, fill.w, fill.h = 0, 0, self.w, self.h
  fill:updateLayout()
end

function Panel:updateFillAlpha(newAlpha)
  self.fill.alpha = newAlpha
  self.fill.baseColor.a = newAlpha
end

function Panel:updateColor(r, g, b, a)
  self.fill:updateColor(r, g, b, a)
end

function Panel:draw(ox, oy, alpha)
  local adjustedAlpha = alpha * self.alpha
  self.fill:draw(self.x + ox, self.y + oy, adjustedAlpha)
  Panel.super.draw(self, ox, oy, alpha)
end

function Panel:__tostring()
  return 'Panel'
end

return Panel
