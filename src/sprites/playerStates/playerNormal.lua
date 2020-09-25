local State = require 'core.state'
local config = require 'gameConfig'

local PlayerNormal = State:extend()

function PlayerNormal:new(player)
  self.player = player
end

function PlayerNormal:enter()
  self.player.jumpForgivenessTimer = 0
  self.currentFrame = math.huge
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
    self.currentFrame = math.huge
  end

  if input:pressed('jump') then
    return 'jumping'
  end

  if input:pressed('action') and player.hasSword then
    return 'swingSword'
  end

  animation.current = 'idle'

  if body.moveVelocity.x ~= 0 and body.velocity.x ~= 0 and body.isOnGround then
    animation.current = 'running'
    animation.flippedH = body.moveVelocity.x < 0
  end

  if not body.isOnGround and body.velocity.y > 0 then
    -- log.debug(body.velocity.y, body.position.y - body.oldPosition.y)
    -- return 'falling'
  end

  local useObject = player.useObject
  if useObject and player.body.aabb:overlaps(useObject.body.aabb) then
    if input:pressed('up') and body.isOnGround then
      useObject.usable:useIt(self)
      player.useObject = nil
    end
  else
    player.useObject = nil
  end

  if player.isExitingLevel then
    return 'exitingLevelDoor'
  end

  if animation.current == 'running' and (animation.frame == 1 or animation.frame == 5) and self.currentFrame ~= animation.frame then
    player.sound:play('footstep', love.math.random(85, 115) / 100)
    self.currentFrame = animation.frame
  end
end

return PlayerNormal
