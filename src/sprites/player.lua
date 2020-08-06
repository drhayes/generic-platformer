local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'
local config = require 'gameConfig'
local TreasureCollider = require 'physics.treasureCollider'
local UsableCollider = require 'physics.usableCollider'

local Player = GameObject:extend()

function Player:new(spec)
  self.x, self.y = spec.x, spec.y
  self.layer = 'player'

  self.input = spec.inputService

  self.animation = spec.animationService:create('player')
  self.animation.current = 'spawning'
  self.animation.animations.spawning.doneSpawning = function()
    self.animation.current = 'idle'
    self.isSpawning = false
  end

  local body = spec.physicsService:newBody(self)
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 2
  body.aabb.halfSize.y = 5
  body.aabbOffset.y = 3
  body.gravityForce.y = (2 * config.player.jumpHeight) / math.pow(config.player.timeToJumpApex, 2)
  self.jumpVelocity = body.gravityForce.y * config.player.timeToJumpApex
  body.collisionLayers = collisionLayers.player
  body.collisionMask = collisionLayers.tilemap + collisionLayers.treasure + collisionLayers.usables
  self.body = body
  table.insert(body.colliders, TreasureCollider(self))
  table.insert(body.colliders, UsableCollider(self))


  self.isSpawning = true
end

function Player:update(dt)
  if self.isSpawning then
    self.animation:update(dt)
    return
  end

  local body, animation = self.body, self.animation
  -- Reset control velocities.
  body.jumpVelocity.x, body.jumpVelocity.y = 0, 0
  body.moveVelocity.x, body.moveVelocity.y = 0, 0

  local input = self.input

  if input:down('right') then
    body.moveVelocity.x = config.player.runVelocity
  elseif input:down('left') then
    body.moveVelocity.x = -config.player.runVelocity
  else
    body.moveVelocity.x = 0
  end

  if input:pressed('jump') and body.isOnGround then
    body.jumpVelocity.y = -self.jumpVelocity
  end

  body:update(dt)

  if body.isOnGround then
    animation.current = 'idle'
  end

  if body.moveVelocity.x ~= 0 and body.velocity.x ~= 0 and body.isOnGround then
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

  -- If we're falling, that overrides most animations.
  if not body.isOnGround and body.velocity.y > 0 then
    if body.moveVelocity.x ~= 0 then
      animation.current = 'runningfalling'
    else
      animation.current = 'falling'
    end
    animation.flippedH = body.moveVelocity.x < 0
  end

  animation:update(dt)

  self.x = body.position.x
  self.y = body.position.y

  body.jumpVelocity.y = 0

  if self.useObject and self.body.aabb:overlaps(self.useObject.body.aabb) then
    if input:pressed('up') and body.isOnGround then
      self.useObject:used(self)
      self.useObject = nil
    end
  else
    self.useObject = nil
  end
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

function Player:setUseObject(obj)
  self.useObject = obj
end

function Player:__tostring()
  return 'Player'
end

return Player
