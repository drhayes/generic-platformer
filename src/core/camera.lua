local GameObject = require 'gobs.gameObject'
local Player = require 'sprites.player'
local config = require 'gameConfig'
local AABB = require 'core.aabb'
local lume = require 'lib.lume'

local NEW_RAIL_SNAP_DELAY = config.camera.newRailSnapDelay

local Camera = GameObject:extend()

function Camera:new(eventBus)
  Camera.super.new(self)
  self.eventBus = eventBus
  self.rails = {}
  self.offsetX, self.offsetY, self.scale = 0, 0, 1
  self.targetX, self.targetY = 0, 0
  self.view = AABB(self.x, self.y, config.graphics.width, config.graphics.height)
  self.counter = 0
  self.counterFactor = 0

  self.eventBus:on('gobAdded', self.onGobAdded, self)
  self.eventBus:on('stopCameraTracking', self.onStopCameraTracking, self)
  self.eventBus:on('focusCamera', self.lookAt, self)
end

function Camera:lookAt(x, y)
  -- Which rail are we closest to?
  local closestRail, dist = nil, math.huge
  local cx, cy
  for i = 1, #self.rails do
    local rail = self.rails[i]
    -- Store new distance and temp nearest point.
    local newDist, tx, ty = rail:nearestPointOnRail(x, y)
    if newDist < dist then
      closestRail = rail
      dist = newDist
      cx, cy = tx, ty
    end
  end
  self.closestRail = closestRail

  local view = self.view
  view.center.x, view.center.y = cx, cy
  self.targetX, self.targetY = cx, cy
  self.offsetX, self.offsetY = lume.round(view:left()), lume.round(view:top())
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
  local cx, cy = 0, 0
  for i = 1, #self.rails do
    local rail = self.rails[i]
    local newDist, tx, ty = rail:nearestPointOnRail(targetX, targetY)
    if newDist < dist then
      closestRail = rail
      dist = newDist
      cx, cy = tx, ty
    end
  end

  if oldRail ~= closestRail then
    if player and player.body.isOnGround then
      self.counter = self.counter + dt
    end
  elseif oldRail == closestRail and self.counter > 0 then
    self.counter = 0
  end

  if self.counter > NEW_RAIL_SNAP_DELAY then
    self.closestRail = closestRail
    self.counter = 0

  elseif oldRail then
    -- Find the closest point on the old rail.
    dist, cx, cy = oldRail:nearestPointOnRail(targetX, targetY) -- luacheck: ignore
  end

  -- Move gently toward whever we're trying to get to.
  local newX = lume.lerp(oldX, cx, .1)
  local newY = lume.lerp(oldY, cy, .1)

  -- Update our exposed offsets.
  view.center.x, view.center.y = newX, newY
  -- self.offsetX, self.offsetY = view:left(), view:top()
  self.offsetX, self.offsetY = lume.round(view:left()), lume.round(view:top())
end

function Camera:addRail(rail)
  log.debug('addRail')
  table.insert(self.rails, rail)
end

function Camera:onGobAdded(gob)
  if not gob:is(Player) then return end
  self.player = gob
end

function Camera:onStopCameraTracking()
  self.targetX, self.targetY = self.player.x, self.player.y
  self.player = nil
end

-- local lg = love.graphics
-- function Camera:draw()
--   lg.push()
--   -- Draw rails.
--   for i = 1, #self.rails do
--     local rail = self.rails[i]
--     if self.closestRail == rail then
--       lg.setColor(0, 1, 0, .8)
--     else
--       lg.setColor(0, 1, 0, .2)
--     end
--     lg.line(rail.x0, rail.y0, rail.x1, rail.y1)
--   end
--   -- Draw center.
--   lg.setColor(0, 1, 0, 1)
--   lg.rectangle('line', self.view.center.x - 2, self.view.center.y - 2, 4, 4)
--   -- Write text of rail switch counter.
--   lg.setColor(1, 1, 1)
--   lg.push('all')
--   lg.origin()
--   lg.print('Counter: ' .. self.counter, 20, 20)
--   lg.pop()
--   lg.pop()
-- end

function Camera:__tostring()
  return 'Camera'
end

return Camera
