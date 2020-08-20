local Object = require 'lib.classic'
local SpriteSpec = require 'sprites.spriteSpec'

local LightLayer = Object:extend()

function LightLayer:new(layerData, offsetX, offsetY)
  self.lights = {}
  for i = 1, #layerData.objects do
    local object = layerData.objects[i]
    if object.shape == 'rectangle' and object.type == 'glimmer' then
      table.insert(self.lights, {
        lightType = 'glimmer',
        x = object.x + offsetX,
        y = object.y + offsetY,
        width = object.width,
        height = object.height,
        })
    end
  end
end

function LightLayer:initialize(eventBus, tileAtlas, physicsService)
  for i = 1, #self.lights do
    local light = self.lights[i]
    local spec = SpriteSpec('glimmer')
    spec.x, spec.y = light.x, light.y
    spec.width, spec.height = light.width, light.height
    eventBus:emit('spawnSpriteBySpec', spec)
  end
end

return LightLayer
