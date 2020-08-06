local Collider = require 'physics.collider'
local collisionLayers = require 'physics.collisionLayers'

local UsableCollider = Collider:extend()

function UsableCollider:new(player)
  self.player = player
  UsableCollider.super.new(self, player.body)
end

function UsableCollider:collide(otherBody)
  if not otherBody:inLayer(collisionLayers.usables) then return false end
  self.player:setUseObject(otherBody.parent)
end

return UsableCollider
