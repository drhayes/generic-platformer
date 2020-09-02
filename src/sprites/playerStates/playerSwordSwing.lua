local State = require 'core.state'
local Coroutine = require 'components.coroutine'

local PlayerSwordSwing = State:extend()

function PlayerSwordSwing:new(player)
  self.player = player
end

function PlayerSwordSwing:enter()
  self.done = false
  local player = self.player
  player:add(Coroutine(function(co)
    local animation = player.animation
    if player.body.isOnGround then
      animation.current = 'swordswinging'
    else
      animation.current = 'swordchopping'
    end
    co:waitForAnimation(animation)
    self.done = true
  end)
)
end

function PlayerSwordSwing:update(dt)
  if self.done then return 'normal' end
end

return PlayerSwordSwing
