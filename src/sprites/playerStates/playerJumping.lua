local State = require 'core.state'
local config = require 'gameConfig'

local JUMP_FLOAT_TIME = config.player.jumpFloatTime

local PlayerJumping = State:extend()

function PlayerJumping:new(player)
  self.player = player
  self.jumpVelocity = player.body.gravityForce.y * config.player.timeToJumpApex
end

function PlayerJumping:enter()
  self.player.jumpForgivenessTimer = math.huge
  self.originalGravityForceY = self.player.body.gravityForce.y
  self.floatGravityForceY  = self.player.body.gravityForce.y / 2
  self.player.body.jumpVelocity.y = -self.jumpVelocity
  self.floatCountdown = 0
end

function PlayerJumping:leave()
  self.player.body.gravityForce.y = self.originalGravityForceY
end


function PlayerJumping:update(dt)
  local player = self.player
  local body, input, animation = player.body, player.input, player.animation
  body.jumpVelocity.x, body.jumpVelocity.y = 0, 0
  body.moveVelocity.x, body.moveVelocity.y = 0, 0

  if input:down('right') then
    body.moveVelocity.x = config.player.airVelocity
  elseif input:down('left') then
    body.moveVelocity.x = -config.player.airVelocity
  else
    body.moveVelocity.x = 0
  end

  if input:pressed('action') and player.hasSword then
    return 'swingSword'
  end

  -- If velocity just flipped and they're still holding jump, halve gravity for a bit.
  if input:down('jump') and body.oldVelocity.y < 0 and body.velocity.y > 0 then
    self.floatCountdown = JUMP_FLOAT_TIME
  end

  if self.floatCountdown > 0 then
    body.gravityForce.y = self.floatGravityForceY
  else
    body.gravityForce.y = self.originalGravityForceY
  end
  self.floatCountdown = self.floatCountdown - dt


  if body.moveVelocity.x ~= 0 then
    animation.current = 'runningfalling'
  else
    animation.current = 'falling'
  end
  animation.flippedH = body.moveVelocity.x < 0

  if body.velocity.y >= config.player.fallingDeathVelocity then
    return 'falling'
  end

  if player.body.isOnGround then
    player.sound:play('land')
    return 'normal'
  end

  if not input:down('jump') then
    return 'falling'
  end
end

return PlayerJumping
