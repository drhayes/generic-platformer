local Object = require 'lib.classic'

local Grid = Object:extend()

function Grid.makeKey(x, y)
  return x .. '|' .. y
end

function Grid.decodeKey(key)
  local x, y = key:match('(%d+)|(%d+)')
  return tonumber(x), tonumber(y)
end

function Grid:new(w, h)
  self.w = w or 0
  self.h = h or 0
  self.minX, self.minY = 0, 0
  self.cells = {}
end

function Grid:get(x, y)
  local cell = self.cells[Grid.makeKey(x, y)]
  if not cell then
    return false
  else
    return cell.value
  end
end

function Grid:set(x, y, value)
  self.w = math.max(self.w, x + 1)
  self.h = math.max(self.h, y + 1)
  self.minX = math.min(self.minX, x)
  self.minY = math.min(self.minY, y)
  self.cells[Grid.makeKey(x, y)] = {
    x = x,
    y = y,
    value = value
  }
end

function Grid:mirrorFlip()
  local newCells = {}
  for gx, gy, oldVal in self:allCells() do
    local x = self.w - gx
    newCells[Grid.makeKey(x, gy)] = {
      x = x,
      y = gy,
      value = oldVal
    }
  end
  self.cells = newCells
end

function Grid:setGrid(dx, dy, grid, value)
  grid:forEach(function(x, y, oldVal)
    self:set(x + dx, y + dy, value)
  end)
end

function Grid:copyGrid(x, y, grid)
  grid:forEach(function(dx, dy, oldVal)
    self:set(x + dx, y + dy, oldVal)
  end)
end

function Grid:setShape(x, y, shape, value)
  for i = 1, #shape do
    local point = shape[i]
    self:set(x + point[1], y + point[2], value)
  end
end

function Grid:canPlaceShape(x, y, shape, ignoreBounds)
  for i = 1, #shape do
    local point = shape[i]
    local cx, cy = x + point[1], y + point[2]
    if not ignoreBounds then
      if cx < 0 or cx >= self.w then return false end
      if cy < 0 or cy >= self.h then return false end
    end
    local key = Grid.makeKey(cx, cy)
    local cell = self.cells[key]
    if cell and cell.value then return false end
  end
  return true
end

function Grid:intersectsGrid(ox, oy, grid)
  return grid:any(function(x, y)
    local value = self:get(x + ox, y + oy)
    if value then return true end
  end)
end

function Grid:forEach(fn)
  for _, current in pairs(self.cells) do
    if current and current.value then
      fn(current.x, current.y, current.value)
    end
  end
end

function Grid:any(fn)
  for _, current in pairs(self.cells) do
    if current and current.value then
      local result = fn(current.x, current.y, current.value)
      if result then return true end
    end
  end
  return false
end

local function defaultCellPrinter(cell, line)
  if cell then
    table.insert(line, '#')
  else
    table.insert(line, '.')
  end
end

function Grid:debugPrint(printer, cellPrinter)
  printer = printer or log.debug
  cellPrinter = cellPrinter or defaultCellPrinter
  printer(self.minX, self.w, self.minY, self.h)
  for y = self.minY, self.h - 1 do
    local line = {}
    for x = self.minX, self.w - 1 do
      cellPrinter(self:get(x, y), line)
    end
    printer(table.concat(line))
  end
end

function Grid:firstValidPosition()
  for y = 0, self.h do
    for x = 0, self.w do
      if self:get(x, y) then
        return x, y
      end
    end
  end
  return nil
end

function Grid:__serialize()
  return self
end


return Grid

