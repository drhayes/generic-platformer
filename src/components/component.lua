local Object = require 'lib.classic'

local Component = Object:extend()

function Component:new()
  self.active = true
end

function Component:update(dt) end
function Component:draw() end
function Component:debugDraw() end

function Component:added(parent)
  self.parent = parent
end

function Component:removed()
  self.parent = nil
end

function Component:gobAdded(gob) end
function Component:gobRemoved(gob) end

return Component
