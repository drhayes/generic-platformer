local config = require 'gameConfig'

local collisionLayers = {}

local flag = 1
for i = 1, #config.physics.layers do
  local layerName = config.physics.layers[i]
  collisionLayers[layerName] = flag
  flag = flag * 2
end

return collisionLayers
