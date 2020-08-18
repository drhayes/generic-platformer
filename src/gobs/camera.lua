local GameObject = require 'gobs.gameObject'
local Player = require 'sprites.player'
local config = require 'gameConfig'
local AABB = require 'core.aabb'
local lume = require 'lib.lume'

local function distToLine(x0, y0, x1, y1, x, y)
  local dx, dy = x1 - x0, y1 - y0
  if dx == 0 and dy == 0 then
    return lume.distance(x0, y0, x, y), x0, y0
  end

  local t = ((x - x0) * dx + (y - y0) * dy) / (dx * dx + dy * dy)

  if t < 0 then
    return lume.distance(x0, y0, x, y), x0, y0
  elseif t > 1 then
    return lume.distance(x1, y1, x, y), x1, y1
  else
    local cx, cy = x0 + t * dx, y0 + t * dy
    return lume.distance(cx, cy, x, y), cx, cy
  end
end

local Camera = GameObject:extend()

function Camera:new(eventBus)
  Camera.super.new(self)
  self.eventBus = eventBus
  self.rails = {}
  self.offsetX, self.offsetY, self.scale = 0, 0, 1
  self.targetX, self.targetY = 0, 0
  self.view = AABB(self.x, self.y, config.graphics.width, config.graphics.height)

  self.eventBus:on('gobAdded', self.onGobAdded, self)
end

function Camera:lookAt(x, y)
  -- Which rail are we closest to?
  local closestRail, dist = nil, math.huge
  local cx, cy
  for i = 1, #self.rails do
    local rail = self.rails[i]
    -- Store new distance and temp nearest point.
    local newDist, tx, ty = distToLine(rail.x0, rail.y0, rail.x1, rail.y1, x, y)
    if newDist < dist then
      closestRail = rail
      dist = newDist
      cx, cy = tx, ty
    end
  end
  self.closestRail = closestRail

  local view = self.view
  view.center.x, view.center.y = cx, cy
  self.offsetX, self.offsetY = math.floor(view:left()), math.floor(view:top())
end

function Camera:update(dt)
  local view = self.view
  local player = self.player
  local targetX, targetY = self.targetX, self.targetY
  if player then
    targetX, targetY = self.player.x, self.player.y
  end
  local oldRail = self.closestRail
  local oldX, oldY = view.center.x, view.center.y

  -- Which rail are we closest to?
  local closestRail, dist = nil, math.huge
  local cx, cy
  for i = 1, #self.rails do
    local rail = self.rails[i]
    -- Store new distance and temp nearest point.
    local newDist, tx, ty = distToLine(rail.x0, rail.y0, rail.x1, rail.y1, targetX, targetY)
    if newDist < dist then
      closestRail = rail
      dist = newDist
      cx, cy = tx, ty
    end
  end

  if oldRail and player and oldRail ~= closestRail and player.body.isOnGround then
    self.closestRail = closestRail
  elseif oldRail then
    -- Find the closest point on the old rail.
    dist, cx, cy = distToLine(oldRail.x0, oldRail.y0, oldRail.x1, oldRail.y1, targetX, targetY)
  end

  -- Move gently toward whever we're trying to get to.
  local newX = lume.smooth(oldX, cx, .2)
  local newY = lume.smooth(oldY, cy, .2)

  -- Update our exposed offsets.
  view.center.x, view.center.y = newX, newY
  self.offsetX, self.offsetY = math.floor(view:left()), math.floor(view:top())
end

function Camera:addRail(rail)
  table.insert(self.rails, rail)
end

function Camera:onGobAdded(gob)
  if not gob:is(Player) then return end
  self.player = gob
end

-- local lg = love.graphics
-- function Camera:draw()
--   lg.push()
--   lg.setColor(0, 1, 0, 1)
--   for i = 1, #self.rails do
--     local rail = self.rails[i]
--     if self.closestRail == rail then
--       lg.setLineWidth(2)
--     else
--       lg.setLineWidth(1)
--     end
--     lg.line(rail.x0, rail.y0, rail.x1, rail.y1)
--   end
--   lg.pop()
-- end

function Camera:__tostring()
  return 'Camera'
end

return Camera
