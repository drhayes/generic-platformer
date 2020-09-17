local Collider = require 'physics.collider'
local collisionLayers = require 'physics.collisionLayers'
local Usable = require 'components.usable'

local UsableCollider = Collider:extend()

function UsableCollider:new(player)
  UsableCollider.super.new(self)
  self.player = player
end

function UsableCollider:collide(otherBody)
  if not otherBody:inLayer(collisionLayers.usables) then return false end
  if not otherBody.parent:has(Usable) then return false end
  self.player:setUseObject(otherBody.parent)
  otherBody.parent.usable.overlapping = self.player
end

return UsableCollider
