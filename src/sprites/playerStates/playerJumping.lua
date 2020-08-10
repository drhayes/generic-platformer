local State = require 'core.state'
local config = require 'gameConfig'

local PlayerJumping = State:extend()

function PlayerJumping:new(player)
  self.player = player
  self.jumpVelocity = player.body.gravityForce.y * config.player.timeToJumpApex
end

function PlayerJumping:enter()
  self.player.jumpForgivenessTimer = math.huge
end

function PlayerJumping:update(dt)
  local player = self.player
  local body, animation = player.body, player.animation
  body.jumpVelocity.y = -self.jumpVelocity

  if body.moveVelocity.x == 0 then
    animation.current = 'jumping'
  else
    animation.current = 'runningjump'
    animation.flippedH = body.moveVelocity.x < 0
  end

  return 'falling'
end

return PlayerJumping
