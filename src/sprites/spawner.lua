local GameObject = require 'gobs.gameObject'

local Spawner = GameObject:extend()

function Spawner:new(spec)
  self.x, self.y = spec.x, spec.y
  self.timer = 0
  self.threshold = 1
  self.running = true

  self.eventBus = spec.eventBus
end

function Spawner:update(dt)
  if not self.running then return end

  self.timer = self.timer + dt
  if self.timer >= self.threshold then
    self.running = false
    self.eventBus:emit('spawnSpriteByType', 'player', self.x, self.y)
  end
end

return Spawner
