local Collider = require 'physics.collider'
local collisionLayers = require 'physics.collisionLayers'

local LevelExitsCollider = Collider:extend()

function LevelExitsCollider:new(player)
  LevelExitsCollider.super.new(self)
  self.player = player
end

function LevelExitsCollider:collide(otherBody)
  if not otherBody:inLayer(collisionLayers.levelExits) then return false end
  self.player.isExitingLevel = true
  otherBody.parent:startLevelExit()
end

return LevelExitsCollider
