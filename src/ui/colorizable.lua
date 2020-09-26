local Object = require 'lib.classic'

local Colorizable = Object:extend()

local default = {
  r = 1,
  g = 1,
  b = 1,
  a = 1,
}

function Colorizable:initColor(colorRef)
  colorRef = colorRef or default
  self.color = {
    r = colorRef.r,
    g = colorRef.g,
    b = colorRef.b,
    a = colorRef.a,
  }
end

function Colorizable:updateColor(r, g, b, a)
  r, b, g, a = r or 1, b or 1, g or 1, a or 1
  if type(r) == 'table' then
    local colorTable = r
    r = colorTable.r or 1
    g = colorTable.g or 1
    b = colorTable.b or 1
    a = colorTable.a or 1
  end
  self.color.r = r
  self.color.b = b
  self.color.g = g
  self.color.a = a
end

function Colorizable:setColor(alpha)
  local c = self.color
  love.graphics.setColor(c.r, c.g, c.b, alpha or 1)
end

return Colorizable
