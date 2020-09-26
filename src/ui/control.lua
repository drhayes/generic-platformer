local Object = require 'lib.classic'

local Control = Object:extend()

local reverseDirs = {
  up = 'down',
  down = 'up',
  left = 'right',
  right = 'left'
}

local lg = love.graphics

function Control:new(x, y, w, h)
  self.x = x or 0
  self.y = y or 0
  self.w = w or 16
  self.h = h or 16
  self.alpha = 1
  self.hidden = false
  self.children = {}
  self.context = nil
end

function Control:update(dt)
  for i = 1, #self.children do
    local child = self.children[i]
    child:update(dt)
  end
end

function Control:draw(ox, oy, alpha)
  ox, oy, alpha = ox or 0, oy or 0, alpha or 1
  local adjustedAlpha = self.alpha * alpha
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.hidden then
      lg.setColor(1, 1, 1, adjustedAlpha)
      child:draw(ox + self.x, oy + self.y, adjustedAlpha)
    end
  end
end

function Control:add(newChild, pos)
  pos = pos or #self.children + 1
  table.insert(self.children, pos, newChild)
  newChild.parent = self
  if self.context and not newChild.context then self.context:set(newChild) end
  self:updateLayout()
  return newChild, pos
end

function Control:clear()
  local children = self.children
  for i = 1, #children do
    local child = children[i]
    child:onRemoved()
    child.parent = nil
    children[i] = nil
  end
end

function Control:updateLayout()
  local layoutChildren = {}
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.isFloating then
      table.insert(layoutChildren, child)
    end
  end
  if self.layout then self:layout(layoutChildren) end
  for i = 1, #self.children do
    local child = self.children[i]
    child:updateLayout()
  end
end

function Control:setNeighbor(dir, control, setReverse)
  if not self.neighbors then self.neighbors = {} end
  self.neighbors[dir] = control
  if setReverse then control:setNeighbor(reverseDirs[dir], self) end
end

function Control:hasNeighbor(dir)
  if not self.neighbors then return false end
  return self.neighbors[dir]
end

-- Return true if the control handled the input.
function Control:userInput(input)
  if not self.context then return false end
  if self.neighbors then
    local neighbor = self.neighbors[input]
    if neighbor and
    (input == 'up' or input == 'down' or input == 'left' or input ==
    'right') then
      self.context:focus(neighbor)
      return true
    end
  end
  if self.parent then return self.parent:userInput(input) end
  return false
end

function Control:onBlur() end
function Control:onFocus() end
function Control:onRemoved() end

function Control:__tostring() return 'Control' end

return Control
