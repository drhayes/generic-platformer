local State = require 'core.state'
local Coroutine = require 'components.coroutine'

local PlayerSpawning = State:extend()

function PlayerSpawning:new(player)
  self.player = player
  self.isDone = false
end

function PlayerSpawning:enter()
  local player = self.player
  player.animation.current = 'spawning'
  player:add(Coroutine(function(co)
    co:waitForAnimation(player.animation)
    player.sound:play('pop')
    self.isDone = true
  end))
  self.player.body.active = false
end

function PlayerSpawning:update(dt)
  if self.isDone then
    return 'introFalling'
  end
end

function PlayerSpawning:leave()
  self.player.body.active = true
end

return PlayerSpawning
