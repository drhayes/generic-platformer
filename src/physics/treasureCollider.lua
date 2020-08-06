local Collider = require 'physics.collider'
local collisionLayers = require 'physics.collisionLayers'

local TreasureCollider = Collider:extend()

function TreasureCollider:new(player)
  self.player = player
  TreasureCollider.super.new(self, player.body)
end

function TreasureCollider:collide(otherBody, collisionNormalX, collisionNormalY)
  if not otherBody:inLayer(collisionLayers.treasure) then return false end

  log.debug('player hitting treasure')
end

return TreasureCollider
