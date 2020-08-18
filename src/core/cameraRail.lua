local Object = require 'lib.classic'
local lume = require 'lib.lume'


local function distToLine(x0, y0, x1, y1, x, y)
  local dx, dy = x1 - x0, y1 - y0
  if dx == 0 and dy == 0 then
    return lume.distance(x0, y0, x, y), x0, y0
  end

  local t = ((x - x0) * dx + (y - y0) * dy) / (dx * dx + dy * dy)

  if t < 0 then
    return lume.distance(x0, y0, x, y), x0, y0
  elseif t > 1 then
    return lume.distance(x1, y1, x, y), x1, y1
  else
    local cx, cy = x0 + t * dx, y0 + t * dy
    return lume.distance(cx, cy, x, y), cx, cy
  end
end


local CameraRail = Object:extend()

function CameraRail:new(x0, y0, x1, y1)
  self.x0, self.y0 = x0, y0
  self.x1, self.y1 = x1, y1
end

function CameraRail:nearestPointOnRail(x, y)
  return distToLine(self.x0, self.y0, self.x1, self.y1, x, y)
end

return CameraRail
