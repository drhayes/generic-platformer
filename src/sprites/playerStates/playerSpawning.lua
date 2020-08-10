local State = require 'core.state'

local PlayerSpawning = State:extend()

function PlayerSpawning:new(player)
  self.player = player
  player.animation.current = 'spawning'
end

function PlayerSpawning:enter()
  self.player.body.active = false
end

function PlayerSpawning:update(dt)
  local player = self.player
  local animation = player.animation.animations[player.animation.current]
  if animation.status == 'paused' then
    return 'normal'
  end
end

function PlayerSpawning:leave()
  self.player.body.active = true
end

return PlayerSpawning
