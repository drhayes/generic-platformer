local GameObject = require 'gobs.gameObject'

local Coroutine = GameObject:extend()

function Coroutine:new(func)
  Coroutine.super.new(self)
  self.coroutine = coroutine.create(func)
end

function Coroutine:update(dt)
  Coroutine.super.update(self, dt)
  local ok, message = coroutine.resume(self.coroutine, self, dt)
  if not ok then
    log.error(message)
  end
  if coroutine.status(self.coroutine) == 'dead' then
    log.debug('dead coroutine', ok, message)
    self.removeMe = true
  end
end

function Coroutine:wait(limit)
  log.debug('wait')
  local count = 0
  while count < limit do
    local _, dt = coroutine.yield()
    count = count + dt
  end
end

function Coroutine:waitUntil(condition)
  log.debug('wait until')
  while not condition() do
    log.debug('loopin')
    coroutine.yield()
  end
end

return Coroutine
