local Collider = require 'physics.collider'
local collisionLayers = require 'physics.collisionLayers'

local TreasureCollider = Collider:extend()

function TreasureCollider:new(player)
  self.player = player
end

function TreasureCollider:collide(otherBody, collisionNormalX, collisionNormalY)
  if not otherBody:inLayer(collisionLayers.treasure) then return false end
  self.player:pickUpTreasure(otherBody.parent)
end

return TreasureCollider
