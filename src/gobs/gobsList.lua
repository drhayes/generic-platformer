local Object = require 'lib.classic'
local lume = require 'lib.lume'

local LAYERS = {
  backgroundColor = 25,
  farBackground = 50,
  background = 100,
  player = 200,
  default = 500,
  foreground = 1000,
  secretArea = 1200,
}

local function gobCompare(a, b)
  local aLayer = a.layer or 'default'
  local bLayer = b.layer or 'default'
  return LAYERS[aLayer] < LAYERS[bLayer]
end


local GobsList = Object:extend()

function GobsList:new(eventBus)
  self.eventBus = eventBus
  self.gobs = {}
end

local removals = {}
function GobsList:update(dt)
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

function GobsList:draw()
  for i = 1, #self.gobs do
    local gob = self.gobs[i]
    gob:draw()
  end
end

function GobsList:add(gob)
  table.insert(self.gobs, gob)
  table.sort(self.gobs, gobCompare)
  gob:gobAdded()
  self.eventBus:emit('gobAdded', gob)
end

function GobsList:remove(gob)
  lume.remove(self.gobs, gob)
  gob:gobRemoved()
  self.eventBus:emit('gobRemoved', gob)
end

function GobsList:clear()
  for i = 1, #self.gobs do
    local gob = self.gobs[i]
    gob:gobRemoved()
  end
  lume.clear(self.gobs)
  self.eventBus:emit('gobsCleared')
end

function GobsList:findFirst(gobType)
  for i = 1, #self.gobs do
    local gob = self.gobs[i]
    if gob:is(gobType) then
      return gob
    end
  end
end

return GobsList
