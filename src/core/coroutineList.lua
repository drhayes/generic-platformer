local Object = require 'lib.classic'
local lume = require 'lib.lume'
local Coroutine = require 'core.coroutine'

local CoroutineList = Object:extend()

function CoroutineList:new()
  self.coroutines = {}
end

local removals = {}
function CoroutineList:update(dt)
  local coroutines = self.coroutines
  lume.clear(removals)
  -- Update'em.
  for i = 1, #coroutines do
    local co = coroutines[i]
    co:update(dt)
    if co.removeMe then
      table.insert(removals, co)
    end
  end
  -- Remove'em.
  for i = 1, #removals do
    local co = removals[i]
    lume.remove(self.coroutines, co)
  end
end

function CoroutineList:add(func)
  table.insert(self.coroutines, Coroutine(func))
end

return CoroutineList
