local State = require 'core.state'
local Coroutine = require 'components.coroutine'

local PlayerFallingDeath = State:extend()

function PlayerFallingDeath:new(player, eventBus)
  self.player = player
  self.eventBus = eventBus
end

function PlayerFallingDeath:enter()
  local player, eventBus = self.player, self.eventBus
  local body = player.body
  -- Player can't collide with things anymore.
  body.collisionMask = 0
  body.moveVelocity.x = 0
  -- Do the scream.
  if love.math.random() < .1 then
    player.sound:play('scream')
  else
    player.sound:play('fall')
  end
  -- Tell camera to stop tracking player.
  eventBus:emit('stopCameraTracking')
  player:add(Coroutine(function(co)
    co:wait(1)
    player.removeMe = true
    eventBus:emit('playerDead', -1)
  end))
end

function PlayerFallingDeath:update(dt)
end

return PlayerFallingDeath
