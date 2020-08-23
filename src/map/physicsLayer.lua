local Object = require 'lib.classic'
local collisionLayers = require 'physics.collisionLayers'

local PhysicsLayer = Object:extend()

function PhysicsLayer:new(layerData, tilesByGid, offsetX, offsetY)
  self.solidParts = {}
  for i = 1, #layerData.objects do
    local object = layerData.objects[i]
    table.insert(self.solidParts, {
      x = object.x + offsetX,
      y = object.y + offsetY,
      width = object.width,
      height = object.height,
    })
  end
end

function PhysicsLayer:initialize(_, _, physicsService)
  for i = 1, #self.solidParts do
    local object = self.solidParts[i]
    local body = physicsService:newBody(
      object.x + object.width / 2, object.y + object.height / 2,
      object.width, object.height
      )
    body.collisionLayers = collisionLayers.tilemap
  end
end

-- function PhysicsLayer:update(dt) end

-- local lg = love.graphics

-- function PhysicsLayer:draw()
--   lg.push()
--   lg.setColor(0, 1, 0, .3)
--   for i = 1, #self.solidParts do
--     local object = self.solidParts[i]
--     lg.rectangle('fill', object.x, object.y, object.width, object.height)
--   end
--   lg.pop()
-- end

return PhysicsLayer
