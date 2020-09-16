local State = require 'core.state'
local Coroutine = require 'components.coroutine'

local PlayerPresentsSword = State:extend()

function PlayerPresentsSword:new(player, swordAnimation)
  self.player = player
  self.swordAnimation = swordAnimation
end

function PlayerPresentsSword:enter()
  local player = self.player
  local body, playerAnim = player.body, player.animation
  body.moveVelocity.x, body.moveVelocity.y = 0, 0
  playerAnim.current = 'present'
  -- Show the sword.
  local swordAnim = player:add(self.swordAnimation)
  swordAnim.current = 'vertical'
  swordAnim.flippedH = true
  swordAnim.flippedV = true
  swordAnim.x, swordAnim.y = -3, -11
  if playerAnim.flippedH then
    swordAnim.flippedH = false
    swordAnim.x = 3
  end
  -- Start the wait.
  player:add(Coroutine(function(co)
    while not player.body.isOnGround do
      coroutine.yield()
    end
    co:wait(.8)
    self.done = true
  end))
end

function PlayerPresentsSword:leave()
  self.swordAnimation.removeMe = true
end

function PlayerPresentsSword:update(dt)
  if self.done then return 'normal' end
end

return PlayerPresentsSword
