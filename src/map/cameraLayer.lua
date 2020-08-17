local Object = require 'lib.classic'
local Camera = require 'gobs.camera'
local CameraRail = require 'core.cameraRail'

local CameraLayer = Object:extend()

function CameraLayer:new(layerData, offsetX, offsetY)
  self.rails = {}
  for i = 1, #layerData.objects do
    local object = layerData.objects[i]
    if object.shape == 'polyline' and #object.polyline == 2 then
      local x0, y0 = object.polyline[1].x, object.polyline[1].y
      local x1, y1 = object.polyline[2].x, object.polyline[2].y
      x0 = x0 + object.x + offsetX
      y0 = y0 + object.y + offsetY
      x1 = x1 + object.x + offsetX
      y1 = y1 + object.y + offsetY
      table.insert(self.rails, CameraRail(x0, y0, x1, y1))
    else
      log.warn('unknown camera object, ignored')
    end
  end
end

function CameraLayer:initialize(eventBus, _, _)
  self.camera = Camera(eventBus)

  for i = 1, #self.rails do
    local rail = self.rails[i]
    self.camera:addRail(rail)
  end

  eventBus:emit('addGob', self.camera)
  eventBus:emit('switchCamera', self.camera)
end

return CameraLayer
