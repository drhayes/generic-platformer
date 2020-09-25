local GameObject = require 'gobs.gameObject'

local Spawner = GameObject:extend()

function Spawner:new(spec)
  Spawner.super.new(self, spec.x, spec.y)
  self.timer = 0
  self.threshold = 1
  self.running = false

  local eventBus = spec.eventBus
  self.eventBus = eventBus
end

function Spawner:gobAdded()
  Spawner.super.gobAdded(self)
  self.eventBus:on('spawnPlayer', self.onSpawnPlayer, self)
end

function Spawner:gobRemoved()
  Spawner.super.gobRemoved(self)
  self.eventBus:off('spawnPlayer', self.onSpawnPlayer)
end

function Spawner:onSpawnPlayer()
  self.eventBus:emit('focusCamera', self.x, self.y)
  self.eventBus:emit('spawnSpriteByType', 'player', self.x, self.y)
end

function Spawner:__tostring()
  return 'Spawner'
end

return Spawner
