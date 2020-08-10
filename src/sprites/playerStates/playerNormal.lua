local State = require 'core.state'
local config = require 'gameConfig'

local PlayerNormal = State:extend()

function PlayerNormal:new(player)
  self.player = player
  self.jumpVelocity = player.body.gravityForce.y * config.player.timeToJumpApex
end

function PlayerNormal:enter()
  self.player.jumpForgivenessTimer = 0
end

function PlayerNormal:update(dt)
  local player = self.player
  local body, animation, input = player.body, player.animation, player.input
  -- Reset control velocities.
  body.jumpVelocity.x, body.jumpVelocity.y = 0, 0
  body.moveVelocity.x, body.moveVelocity.y = 0, 0

  if input:down('right') then
    body.moveVelocity.x = config.player.runVelocity
  elseif input:down('left') then
    body.moveVelocity.x = -config.player.runVelocity
  else
    body.moveVelocity.x = 0
  end

  if input:pressed('jump') then
    return 'jumping'
  end

  -- body:update(dt)

  animation.current = 'idle'

  if body.moveVelocity.x ~= 0 and body.velocity.x ~= 0 and body.isOnGround then
    animation.current = 'running'
    animation.flippedH = body.moveVelocity.x < 0
  end

  if not body.isOnGround and body.velocity.y > 0 then
    return 'falling'
  end

  -- animation:update(dt)

  -- player.x = body.position.x
  -- player.y = body.position.y

  if player.useObject and player.body.aabb:overlaps(player.useObject.body.aabb) then
    if input:pressed('up') and body.isOnGround then
      player.useObject:used(self)
      player.useObject = nil
    end
  else
    player.useObject = nil
  end
end

return PlayerNormal
