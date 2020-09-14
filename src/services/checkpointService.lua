local Object = require 'lib.classic'

local CheckpointService = Object:extend()

function CheckpointService:new(eventBus)
  self.eventBus = eventBus
  self.tracking = {}

  eventBus:on('playerDead', self.onPlayerDead, self)
end

function CheckpointService:add(spec)
  table.insert(self.tracking, spec)
end

function CheckpointService:onPlayerDead()
  -- Copy the tracking table to a separate place and clear the original.
  -- As GOBs add to the global list they will add themselves to the tracking table.
  local tracking = self.tracking
  self.tracking = {}
  -- Iterate the tracking table and spawn those GOBs.
  local eventBus = self.eventBus
  for i = 1, #tracking do
    local spec = tracking[i]
    eventBus:emit('spawnSpriteBySpec', spec)
  end
end

return CheckpointService
