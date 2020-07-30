local GameObject = require 'gobs.gameObject'
local Drawable = require 'gobs.drawable'
local collisionLayers = require 'core.collisionLayers'
local config = require 'gameConfig'

local Player = GameObject:extend()
-- TODO: Do I *need* drawable yet?
Player:implement(Drawable)

function Player:new(spec)
  self.x, self.y = spec.x, spec.y

  self.animation = spec.animationService:create('player')
  self.animation.current = 'idle'
  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 2
  body.aabb.halfSize.y = 5
  body.aabbOffset.y = 3
  -- body.friction = 0.95
  body.gravityForce.y = (2 * config.player.jumpHeight) / math.pow(config.player.timeToJumpApex, 2)
  self.jumpVelocity = body.gravityForce.y * config.player.timeToJumpApex
  log.debug(body.gravityForce, self.jumpVelocity)
  body.collisionLayer = collisionLayers.player
  body.collisionMask = collisionLayers.tilemap
  self.body = body
end

function Player:update(dt)
  local body = self.body

  if love.keyboard.isDown('right') then
    body.moveVelocity.x = config.player.runVelocity
  elseif love.keyboard.isDown('left') then
    body.moveVelocity.x = -config.player.runVelocity
  else
    body.moveVelocity.x = 0
  end

  -- Change this when there's hurting and stuff.
  if body.velocity.x ~= 0 and body.moveVelocity.x == 0 then
    body.velocity.x = 0
  end

  if love.keyboard.isDown('space') and body.isOnGround then
    body.jumpVelocity.y = -self.jumpVelocity
  end

  self.animation:update(dt)
  body:update(dt)
  self.x = body.position.x
  self.y = body.position.y

  body.jumpVelocity.y = 0
end

local lg = love.graphics

function Player:draw()
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.animation:draw(self.x, self.y)
  lg.setColor(0, 1, 0, .3)
  lg.rectangle('fill', self.body.aabb:bounds())
  lg.pop()
end

function Player:__tostring()
  return 'Player'
end

return Player
