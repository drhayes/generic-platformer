local State = require 'core.state'

local PlayerIntroFalling = State:extend()

function PlayerIntroFalling:new(player)
  self.player = player
end

function PlayerIntroFalling:enter()
  self.player.animation.current = 'falling'
end

function PlayerIntroFalling:update(dt)
  local player = self.player
  local body = player.body

  if body.isOnGround then
    player.sound:play('land')
    return 'normal'
  end
end

return PlayerIntroFalling
