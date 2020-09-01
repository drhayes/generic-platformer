local State = require 'core.state'
local Coroutine = require 'components.coroutine'

local PlayerSwordSwing = State:extend()

function PlayerSwordSwing:new(player)
  self.player = player
end

function PlayerSwordSwing:enter()
  self.done = false
  self.player:add(Coroutine(function(co)
    local animation = self.player.animation
    animation.current = 'swordswinging'
    co:waitForAnimation(animation)
    self.done = true
  end)
)
end

function PlayerSwordSwing:update(dt)
  if self.done then return 'normal' end
end

return PlayerSwordSwing
