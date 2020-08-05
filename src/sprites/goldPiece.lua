local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'core.collisionLayers'

local GoldPiece = GameObject:extend()

function GoldPiece:new(spec)
  self.x, self.y = spec.x, spec.y
  self.layer = 'player'

  self.animation = spec.animationService:create('goldPiece')

  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 1
  body.aabb.halfSize.y = 1.5
  body.collisionLayer = collisionLayers.treasure
  body.collisionMask = collisionLayers.tilemap
  self.body = body

  local speed = 80
  local angle = love.math.randomNormal(math.rad(15), math.rad(-90))
  body.moveVelocity.x = math.cos(angle) * speed
  body.moveVelocity.y = math.sin(angle) * speed
  body.gravityForce.y = 200
  log.debug(body.moveVelocity)
end

function GoldPiece:update(dt)
  self.body:update(dt)
  -- self.body.moveVelocity.x = 0
  -- self.body.moveVelocity.y = 0

  self.animation:update(dt)

  self.x, self.y = self.body.position.x, self.body.position.y
end

local lg = love.graphics

function GoldPiece:draw()
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.animation:draw(self.x, self.y)
  lg.pop()
end

function GoldPiece:__tostring()
  return 'GoldPiece'
end

return GoldPiece
