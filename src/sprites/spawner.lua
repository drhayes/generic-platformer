local GameObject = require 'gobs.gameObject'

local Spawner = GameObject:extend()

function Spawner:new(spec)
  Spawner.super.new(self)
  self.x, self.y = spec.x, spec.y
  self.timer = 0
  self.threshold = 1
  self.running = true

  local eventBus = spec.eventBus
  eventBus:on('playerDead', self.onPlayerDead, self)
  self.eventBus = eventBus
end

function Spawner:update(dt)
  Spawner.super.update(self, dt)
  if not self.running then return end

  self.timer = self.timer + dt
  if self.timer >= self.threshold then
    self.running = false
    self.eventBus:emit('spawnSpriteByType', 'player', self.x, self.y)
  end
end

function Spawner:onPlayerDead()
  self.running = true
end

function Spawner:__tostring()
  return 'Spawner'
end

return Spawner
