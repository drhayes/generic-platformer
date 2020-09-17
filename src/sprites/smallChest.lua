local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'
local Coroutine = require 'components.coroutine'
local Usable = require 'components.usable'

local SmallChest = GameObject:extend()

function SmallChest:new(spec)
  SmallChest.super.new(self, spec.x, spec.y)
  self.layer = 'background'
  self.eventBus = spec.eventBus

  local animation = spec.animationService:create('smallChest')
  animation.current = 'closed'
  self.animation = self:add(animation)

  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 6
  body.aabb.halfSize.y = 6
  body.aabbOffset.x = 2
  body.aabbOffset.y = 4
  body.collisionLayers = collisionLayers.usables
  self.body = self:add(body)

  self.usable = self:add(Usable(function(user)
    self:add(Coroutine(function(co)
      self.usable.isUsable = false
      animation.current = 'opening'
      co:waitForAnimation(animation)
      for i = 1, 10 do
        co:wait(.12)
        self.eventBus:emit('spawnSpriteByType', 'goldCoin', self.x, self.y)
      end
    end))
  end))
end

function SmallChest:__tostring()
  return 'SmallChest'
end

return SmallChest
