local State = require 'core.state'
local config = require 'gameConfig'

local PlayerExitingLevelDoor = State:extend()

function PlayerExitingLevelDoor:new(player, eventBus)
  self.player = player
  self.eventBus = eventBus
end

function PlayerExitingLevelDoor:enter()
  self.isMovingRight = self.player.body.moveVelocity.x > 0
  self.startX = self.player.body.position.x
  self.player.animation.current = 'running'
  self.player.animation.flippedH = not self.isMovingRight
end

function PlayerExitingLevelDoor:update(dt)
  -- This state doesn't exit by itself. Only external things can get stop this state.
  local sign = self.isMovingRight and 1 or -1
  local body = self.player.body
  body.moveVelocity.x = config.player.runVelocity * sign * .5

  if math.abs(body.position.x - self.startX) > 30 then
    body.moveVelocity.x = 0
  end
end

return PlayerExitingLevelDoor
