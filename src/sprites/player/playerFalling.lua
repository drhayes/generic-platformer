local State = require 'core.state'
local config = require 'gameConfig'

local PlayerFalling = State:extend()

function PlayerFalling:new(player, eventBus)
  self.player = player
  self.jumpVelocity = player.body.gravityForce.y * config.player.timeToJumpApex
  self.eventBus = eventBus
end

function PlayerFalling:enter()
  self.jumpForgivenessTimer = 0
end

function PlayerFalling:update(dt)
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

  self.jumpForgivenessTimer = self.jumpForgivenessTimer + dt

  if input:pressed('jump') and body.velocity.y > 0 and self.jumpForgivenessTimer <= config.player.jumpForgivenessThresholdSeconds then
    body.jumpVelocity.y = -self.jumpVelocity
    self.jumpForgivenessTimer = config.player.jumpForgivenessThresholdSeconds
  end


  player.body:update(dt)

  if body.moveVelocity.x ~= 0 then
    animation.current = 'runningfalling'
  else
    animation.current = 'falling'
  end
  animation.flippedH = body.moveVelocity.x < 0

  player.animation:update(dt)

  player.x = body.position.x
  player.y = body.position.y

  if body.velocity.y >= config.player.fallingDeathVelocity then
    player.removeMe = true
    self.eventBus:emit('playerDead')
  end

  if player.body.isOnGround then
    return 'normal'
  end
end

return PlayerFalling
