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
    self:remove(gob)
  end
end

function GobsService:add(gob)
  table.insert(self.gobs, gob)
  gob:gobAdded()
  self.eventBus:emit('gobAdded', gob)
end

function GobsService:remove(gob)
  lume.remove(self.gobs, gob)
  gob:gobRemoved()
  self.eventBus:emit('gobRemoved', gob)
end

-- This is a command received from the event bus.
function GobsService:onAddGob(gob)
  self:add(gob)
end

function GobsService:clear()
  for i = 1, #self.gobs do
    local gob = self.gobs[i]
    gob:gobRemoved()
  end
  lume.clear(self.gobs)
  self.eventBus:emit('gobsCleared')
end

return GobsService
