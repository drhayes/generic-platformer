local Control = require 'ui.control'

-- A semantic container of other controls that does nothing but contain
-- other controls for layouts and things.
local Frame = Control:extend()

--[[
function Frame:draw(ox, oy, alpha)
  ox, oy = ox or 0, oy or 0
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', self.x + ox, self.y + oy, self.w, self.h)
  Frame.super.draw(self, ox, oy, alpha)
end
--]]

function Frame:onFocus()
  -- Focus our first child.
  if self.context and #self.children > 0 then
    local firstChild = self.children[1]
    self.context:focus(firstChild)
  end
end

function Frame:__tostring()
  return 'Frame'
end

return Frame
