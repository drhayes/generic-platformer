local State = require 'core.state'

local PlayerSpawning = State:extend()

function PlayerSpawning:new(player)
  self.player = player
  player.animation.current = 'spawning'
end

function PlayerSpawning:update(dt)
  local player = self.player
  player.animation:update(dt)
  local animation = player.animation.animations[player.animation.current]
  if animation.status == 'paused' then
    return 'normal'
  end
end

return PlayerSpawning
