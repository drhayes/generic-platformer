local Object = require 'lib.classic'
local lume = require 'lib.lume'

local GobsService = Object:extend()

function GobsService:new(eventBus)
  self.eventBus = eventBus
  self.gobs = {}
  eventBus:on('addGob', self.onAddGob, self)
end

local removals = {}
function GobsService:update(dt)
  local gobs = self.gobs
  lume.clear(removals)
  -- Update'em.
  for i = 1, #gobs do
    local gob = gobs[i]
    gob:update(dt)
    if gob.removeMe then
      table.insert(removals, gob)
    end
  end
  -- Remove'em.
  for i = 1, #removals do
    local gob = removals[i]
    lume.remove(gobs, gob)
    self.eventBus:emit('gobRemoved', gob)
  end
end

function GobsService:onAddGob(gob)
  table.insert(self.gobs, gob)
  self.eventBus:emit('gobAdded', gob)
end

function GobsService:clear()
  lume.clear(self.gobs)
  self.eventBus:emit('gobsCleared')
end

return GobsService
