local Object = require 'lib.classic'

local Spawner = Object:extend()

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
    self.eventBus:emit('spawnSprite', 'player', self.x, self.y)
  end
end

function Spawner:draw()
  -- Invisible!
end

return Spawner
