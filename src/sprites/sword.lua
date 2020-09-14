local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'

local Sword = GameObject:extend()

function Sword:new(spec)
  Sword.super.new(self, spec.x, spec.y)
  self.layer = 'background'

  local animation = self:add(spec.animationService:create('sword'))
  animation.current = 'vertical'

  local body = spec.physicsService:newBody(spec.x, spec.y, 8, 16)
  body.collisionLayers = collisionLayers.treasure
  self:add(body)

  spec.checkpointService:add(spec)
end

function Sword:__tostring()
  return 'Sword'
end

return Sword
