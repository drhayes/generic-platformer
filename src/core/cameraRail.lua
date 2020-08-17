local Object = require 'lib.classic'

local CameraRail = Object:extend()

function CameraRail:new(x0, y0, x1, y1)
  self.x0, self.y0 = x0, y0
  self.x1, self.y1 = x1, y1
end

return CameraRail
