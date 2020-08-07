local Object = require 'lib.classic'
local Camera = require 'gobs.camera'
local AABB = require 'core.aabb'

local CameraLayer = Object:extend()

function CameraLayer:new(layerData, offsetX, offsetY)
  self.regions = {}
  for i = 1, #layerData.objects do
    local object = layerData.objects[i]
    if object.shape == 'rectangle' then
      table.insert(self.regions, AABB(
        object.x + object.width / 2 + offsetX,
        object.y + object.height / 2 + offsetY,
        object.width,
        object.height
      ))
    elseif object.shape == 'point' and object.properties.isInitial then
      self.initial = {
        x = object.x + offsetX,
        y = object.y + offsetY
      }
    end
  end
end

function CameraLayer:initialize(eventBus, _, _)
  self.camera = Camera(eventBus)

  if self.initial then
    self.camera:lookAt(self.initial.x, self.initial.y)
  end

  for i = 1, #self.regions do
    local region = self.regions[i]
    self.camera:addRegion(region)
  end

  eventBus:emit('addGob', self.camera)
  eventBus:emit('switchCamera', self.camera)
end

return CameraLayer
