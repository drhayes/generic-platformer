local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'core.collisionLayers'

local SmallChest = GameObject:extend()

function SmallChest:new(spec)
  self.x, self.y = spec.x, spec.y
  self.layer = 'background'

  self.animation = spec.animationService:create('smallChest')

  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 6
  body.aabb.halfSize.y = 6
  body.aabbOffset.x = 2
  body.aabbOffset.y = 4
  body.collisionLayer = collisionLayers.treasure
  self.body = body
end

function SmallChest:update(dt)
  self.body:update(dt)
  self.animation:update(dt)
end

local lg = love.graphics

function SmallChest:draw()
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.animation:draw(self.x, self.y)
  lg.pop()
end

function SmallChest:__tostring()
  return 'SmallChest'
end

return SmallChest
