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

  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 2
  body.aabb.halfSize.y = 5
  body.aabbOffset.y = 3
  body.gravityForce.y = (2 * config.player.jumpHeight) / math.pow(config.player.timeToJumpApex, 2)
  self.jumpVelocity = body.gravityForce.y * config.player.timeToJumpApex
  body.collisionLayer = collisionLayers.player
  body.collisionMask = collisionLayers.tilemap
  self.body = body
end

function Player:update(dt)
  local body, animation = self.body, self.animation

  if love.keyboard.isDown('right') then
    body.moveVelocity.x = config.player.runVelocity
  elseif love.keyboard.isDown('left') then
    body.moveVelocity.x = -config.player.runVelocity
  else
    body.moveVelocity.x = 0
  end

  if love.keyboard.isDown('space') and body.isOnGround then
    body.jumpVelocity.y = -self.jumpVelocity
  end

  if body.isOnGround then
    animation.current = 'idle'
  end

  if body.moveVelocity.x ~= 0 and body.isOnGround then
    animation.current = 'running'
    animation.flippedH = body.moveVelocity.x < 0
  end

  -- If we're jumping, do that.
  if body.jumpVelocity.y < 0 then
    if body.moveVelocity.x == 0 then
      animation.current = 'jumping'
    else
      animation.current = 'runningjump'
      animation.flippedH = body.moveVelocity.x < 0
    end
  end

  animation:update(dt)
  body:update(dt)

  -- If we're falling, that overrides most animations.
  if not body.isOnGround and body.velocity.y > 0 then
    animation.current = 'falling'
    animation.flippedH = body.moveVelocity.x < 0
  end

  self.x = body.position.x
  self.y = body.position.y

  body.jumpVelocity.y = 0
end

local lg = love.graphics

function Player:draw()
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.animation:draw(self.x, self.y)
  -- lg.setColor(0, 1, 0, .3)
  -- lg.rectangle('fill', self.body.aabb:bounds())
  lg.pop()
end

function Player:__tostring()
  return 'Player'
end

return Player
