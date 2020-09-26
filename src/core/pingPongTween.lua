local Object = require 'lib.classic'

local PingPongTween = Object:extend()

function PingPongTween:new(obj, duration, low, high)
  self.obj = obj
  self.duration = duration
  self.low = low
  self.high = high
  self.delta = 1
  self.clock = 0
  self.keys = {}
  for key, _ in pairs(self.low) do
    table.insert(self.keys, key)
  end
  self:updateValues()
end

function PingPongTween:updateValues()
  local obj = self.obj
  local low = self.low
  local high = self.high
  local t = self.clock / self.duration

  for i = 1, #self.keys do
    local key = self.keys[i]
    local lowVal = low[key]
    local highVal = high[key]
    local val = (highVal - lowVal) * t + lowVal
    obj[key] = val
  end
end

function PingPongTween:update(dt)
  self.clock = self.clock + self.delta * dt
  if self.clock > self.duration then
    self.clock = self.duration
    self.delta = -1
  end
  if self.clock < 0 then
    self.clock = 0
    self.delta = 1
  end
  self:updateValues()
end

return PingPongTween
