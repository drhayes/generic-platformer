local State = require 'core.state'
local config = require 'gameConfig'

local PlayerFalling = State:extend()

function PlayerFalling:new(player, eventBus)
  self.player = player
  self.eventBus = eventBus
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

  player.jumpForgivenessTimer = player.jumpForgivenessTimer + dt

  if input:pressed('jump') and body.velocity.y > 0 and player.jumpForgivenessTimer <= config.player.jumpForgivenessThresholdSeconds then
    return 'jumping'
  end


  if body.moveVelocity.x ~= 0 then
    animation.current = 'runningfalling'
  else
    animation.current = 'falling'
  end
  animation.flippedH = body.moveVelocity.x < 0

  if body.velocity.y >= config.player.fallingDeathVelocity then
    player.removeMe = true
    self.eventBus:emit('playerDead')
  end

  if player.body.isOnGround then
    player.sound:play('land')
    return 'normal'
  end
end

return PlayerFalling
