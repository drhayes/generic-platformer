local State = require 'core.state'

local PlayerPresentsSword = State:extend()

function PlayerPresentsSword:new(player)
  self.player = player
end

function PlayerPresentsSword:enter()
  local player = self.player
  local body = player.body
  local playerAnim, swordAnim = player.animation, player.swordAnimation
  playerAnim.current = 'present'
  swordAnim.active = true
  swordAnim.current = 'vertical'
  swordAnim.flippedH = true
  swordAnim.flippedV = true
  swordAnim.x, swordAnim.y = -2, -11
  body.moveVelocity.x, body.moveVelocity.y = 0, 0

  self.wait = 0
end

function PlayerPresentsSword:leave()
  local swordAnim = self.player.swordAnimation
  swordAnim.current = 'horizontal'
  swordAnim.flippedH = false
  swordAnim.flippedV = false
  swordAnim.x, swordAnim.y = 0, 0
end

function PlayerPresentsSword:update(dt)
  self.wait = self.wait + dt
  if self.wait > .8 then
    return 'normal'
  end
end

return PlayerPresentsSword
