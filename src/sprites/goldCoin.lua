local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'
local Coroutine = require 'components.coroutine'

local JUMP_HEIGHT = 24
local APEX_TIME = .5

local GoldCoin = GameObject:extend()

function GoldCoin:new(spec)
  GoldCoin.super.new(self, spec.x, spec.y)
  self.layer = 'player'

  self.animation = self:add(spec.animationService:create('goldCoin'))

  local body = spec.physicsService:newBody(spec.x, spec.y, 2, 3)
  body.collisionMask = collisionLayers.tilemap
  body.resolutionType = 'bounceOnce'
  self.body = self:add(body)

  body.gravityForce.y = (2 * JUMP_HEIGHT) / math.pow(APEX_TIME, 2)
  local speed = body.gravityForce.y * APEX_TIME
  local angle = love.math.randomNormal(math.rad(5), math.rad(-90))
  body.jumpVelocity.x = math.cos(angle) * speed
  body.jumpVelocity.y = math.sin(angle) * speed

  -- For the first bit of time it is in existence, it is not pickupable.
  self:add(Coroutine(function(co, dt)
    co:wait(.5)
    body.collisionLayers = collisionLayers.treasure
  end))
end

function GoldCoin:update(dt)
  GoldCoin.super.update(self, dt)
  local body = self.body
  body.jumpVelocity.x, body.jumpVelocity.y = 0, 0
end

function GoldCoin:__tostring()
  return 'GoldCoin'
end

return GoldCoin
