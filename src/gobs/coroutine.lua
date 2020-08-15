local GameObject = require 'gobs.gameObject'

local Coroutine = GameObject:extend()

function Coroutine:new(func)
  Coroutine.super.new(self)
  self.coroutine = coroutine.create(func)
end

function Coroutine:update(dt)
  Coroutine.super.update(self, dt)
  local ok = coroutine.resume(self.coroutine, self, dt)
  if not ok or coroutine.status(self.coroutine) == 'dead' then
    self.removeMe = true
  end
end

function Coroutine:wait(limit)
  local count = 0
  while count < limit do
    local _, dt = coroutine.yield()
    count = count + dt
  end
end

function Coroutine:waitUntil(condition)
  while not condition() do
    coroutine.yield()
  end
end

return Coroutine
