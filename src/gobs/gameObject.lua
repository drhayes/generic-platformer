local Object = require 'lib.classic'
local lume = require 'lib.lume'

local GameObject = Object:extend()

function GameObject:new()
  self.components = {}
  self.x, self.y = 0, 0
end

function GameObject:add(component)
  table.insert(self.components, component)
  component:added(self)
end

function GameObject:remove(component)
  lume.remove(self.components, component)
  component:removed()
end

local removals = {}
function GameObject:update(dt)
  lume.clear(removals)
  -- Update.
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then
      component:update(dt)
    end
    if component.removeMe then
      table.insert(removals, component)
    end
  end
  -- Remove.
  for i = 1, #removals do
    local component = removals[i]
    self:remove(component)
  end
end

function GameObject:draw(offsetX, offsetY, scale, alpha)
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then
      component:draw(offsetX, offsetY, scale, alpha)
      -- component:debugDraw()
    end
  end
end

return GameObject
