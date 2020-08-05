local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'core.collisionLayers'

local JUMP_HEIGHT = 24
local APEX_TIME = .5

local GoldCoin = GameObject:extend()

function GoldCoin:new(spec)
  self.x, self.y = spec.x, spec.y
  self.layer = 'player'

  self.animation = spec.animationService:create('goldCoin')

  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 1
  body.aabb.halfSize.y = 1.5
  body.collisionLayer = collisionLayers.treasure
  body.collisionMask = collisionLayers.tilemap
  self.body = body

  body.gravityForce.y = (2 * JUMP_HEIGHT) / math.pow(APEX_TIME, 2)
  local speed = body.gravityForce.y * APEX_TIME
  local angle = love.math.randomNormal(math.rad(15), math.rad(-90))
  body.jumpVelocity.x = math.cos(angle) * speed
  body.jumpVelocity.y = math.sin(angle) * speed
end

function GoldCoin:update(dt)
  self.body:update(dt)
  self.body.jumpVelocity.x, self.body.jumpVelocity.y = 0, 0
  self.animation:update(dt)
  self.x, self.y = self.body.position.x, self.body.position.y
end

local lg = love.graphics

function GoldCoin:draw()
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.animation:draw(self.x, self.y)
  lg.pop()
end

function GoldCoin:__tostring()
  return 'GoldCoin'
end

return GoldCoin
