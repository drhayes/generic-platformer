local Component = require 'components.component'

local Usable = Component:extend()

function Usable:new(used)
  Usable.super.new(self)
  self.used = used
  self.isUsable = true
end

function Usable:useIt(user)
  -- Use a period here cuz we're invoking a function someone else gave us.
  self.used()
end

function Usable:update(dt)
  -- Are we still overlapping?
  local stillOverlapping = false
  if self.overlapping then
    local body = self.parent.body
    local otherBody = self.overlapping.body
    stillOverlapping = otherBody.aabb:overlaps(body.aabb)
  end

  if not stillOverlapping then
    self.overlapping = nil
  end
end

return Usable
