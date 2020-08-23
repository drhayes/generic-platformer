local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'

local Sword = GameObject:extend()

function Sword:new(spec)
  Sword.super.new(self, spec.x, spec.y)
  self.layer = 'background'

  local animation = spec.animationService:create('sword')
  animation.current = 'floating'
  self:add(animation)

  local body = spec.physicsService:newBody(spec.x, spec.y, 8, 16)
  body.collisionLayers = collisionLayers.treasure
  self:add(body)

  self.originalY = spec.y
  self.time = 0
  self.offsetY = 0
end

function Sword:__tostring()
  return 'Sword'
end

return Sword
