local Object = require 'lib.classic'
local PingPong = require 'core.pingPongTween'

-- Steel.
local FOCUS_COLOR_LOW = {
  b = 0.4,
  g = 0.26666666666667,
  r = 0.22745098039216,
}

-- Archaeon.
local FOCUS_COLOR_HIGH = {
  b = 0.91372549019608,
  g = 0.5843137254902,
  r = 0,
}

local HasFocusColor = Object:extend()

function HasFocusColor:initFocusColor(low, high)
  low = low or FOCUS_COLOR_LOW
  high = high or FOCUS_COLOR_HIGH
  self.focusTween = PingPong(self.color, 0.5, low, high)
end

function HasFocusColor:updateFocusColor(dt)
  self.focusTween:update(dt)
end

-- Should look the same as Control:draw except for the focus color thing.
function HasFocusColor:drawChildrenFocused(ox, oy, alpha)
  ox, oy, alpha = ox or 0, oy or 0, alpha or 1
  local adjustedAlpha = self.alpha * alpha
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.hidden then
      self:setColor(adjustedAlpha)
      child:draw(ox + self.x, oy + self.y, adjustedAlpha)
    end
  end
end

return HasFocusColor
