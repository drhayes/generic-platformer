local Object = require 'lib.classic'

local Coroutine = Object:extend()

function Coroutine:new(func)
  self.coroutine = coroutine.create(func)
end

function Coroutine:update(dt)
  local ok, message = coroutine.resume(self.coroutine, self, dt)
  if not ok then
    log.error(message)
  end
  if coroutine.status(self.coroutine) == 'dead' then
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

function Coroutine:waitUntil(condition, arg1)
  while not condition(arg1) do
    coroutine.yield()
  end
end

return Coroutine
