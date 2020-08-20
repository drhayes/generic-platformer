local Object = require 'lib.classic'
local Glimmer = require 'sprites.glimmer'

local LightLayer = Object:extend()

function LightLayer:new(layerData, offsetX, offsetY)
  self.lights = {}
  for i = 1, #layerData.objects do
    local object = layerData.objects[i]
    if object.shape == 'rectangle' and object.type == 'glimmer' then
      table.insert(self.lights, Glimmer(
        object.x + offsetX,
        object.y + offsetY,
        object.width,
        object.height
        )
      )
    end
  end
end

function LightLayer:initialize(eventBus, tileAtlas, physicsService)
  for i = 1, #self.lights do
    local light = self.lights[i]
    eventBus:emit('addGob', light)
  end
end

return LightLayer
