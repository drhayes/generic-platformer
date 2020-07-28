local Object = require 'lib.classic'

local GobsService = Object:extend()

function GobsService:new(eventBus)
  self.eventBus = eventBus
  self.gobs = {}
  eventBus:on('addGob', self.onAddGob, self)
end

function GobsService:update(dt)
  local gobs = self.gobs
  for i = 1, #gobs do
    local gob = gobs[i]
    gob:update(dt)
  end
end

function GobsService:onAddGob(gob)
  table.insert(self.gobs, gob)
  self.eventBus:emit('gobAdded', gob)
end

return GobsService
