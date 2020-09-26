local GameObject = require 'gobs.gameObject'
local Player = require 'sprites.player'
local config = require 'gameConfig'
local AABB = require 'core.aabb'
local lume = require 'lib.lume'
local FontService = require 'services.fontService'

local lg = love.graphics
local SCREEN_WIDTH, SCREEN_HEIGHT = config.graphics.width, config.graphics.height
local NEW_RAIL_SNAP_DELAY = config.camera.newRailSnapDelay
local CAMERA_LERP_FACTOR = config.camera.lerpFactor

local Camera = GameObject:extend()

function Camera:new(eventBus)
  Camera.super.new(self)
  self.eventBus = eventBus
  self.rails = {}
  self.offsetX, self.offsetY, self.scale = 0, 0, 1
  self.targetX, self.targetY = 0, 0
  self.view = AABB(self.x, self.y, SCREEN_WIDTH, SCREEN_HEIGHT)
  self.counter = 0
  self.counterFactor = 0
  self.canvas = lg.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)
  self.fadeTint = 0
  self.fadeDelta = 1
  self.windowFactor = 1

  self.screenWidth, self.screenHeight = lg.getDimensions()

  self.eventBus:on('gobAdded', self.onGobAdded, self)
  self.eventBus:on('gobRemoved', self.onGobRemoved, self)
  self.eventBus:on('gobsCleared', self.onGobsCleared, self)
  self.eventBus:on('stopCameraTracking', self.onStopCameraTracking, self)
  self.eventBus:on('focusCamera', self.lookAt, self)
  self.eventBus:on('setWindowFactor', self.onSetWindowFactor, self)
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
  self.targetX, self.targetY = x, y
  self.offsetX, self.offsetY = view:left(), view:top()
end

function Camera:update(dt)
  self.fadeTint = lume.clamp(self.fadeTint + self.fadeDelta * dt, 0, 1)
  local view = self.view
  local player = self.player
  if player then
    self.targetX = player.x
    self.targetY = player.y
  end
  local targetX, targetY = self.targetX, self.targetY
  local oldRail = self.closestRail
  local oldX, oldY = view.center.x, view.center.y

  -- Which rail are we closest to?
  local closestRail, dist = nil, math.huge
  local cx, cy = targetX, targetY
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
  local newX = lume.lerp(oldX, cx, CAMERA_LERP_FACTOR)
  local newY = lume.lerp(oldY, cy, CAMERA_LERP_FACTOR)

  -- Update our exposed offsets.
  view.center.x, view.center.y = newX, newY
  self.offsetX, self.offsetY = view:left(), view:top()
end

function Camera:draw(gobsList)
  lg.setCanvas(self.canvas)
  lg.setScissor(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
  lg.push()
  lg.clear()
  lg.translate(-lume.round(self.offsetX), -lume.round(self.offsetY))
  gobsList:draw()

  -- -- Draw rails.
  -- for i = 1, #self.rails do
  --   local rail = self.rails[i]
  --   if self.closestRail == rail then
  --     lg.setColor(0, 1, 0, .8)
  --   else
  --     lg.setColor(0, 1, 0, .2)
  --   end
  --   lg.line(rail.x0, rail.y0, rail.x1, rail.y1)
  -- end
  -- -- Draw center.
  -- lg.setColor(0, 1, 0, 1)
  -- lg.rectangle('line', self.view.center.x - 2, self.view.center.y - 2, 4, 4)
  -- -- Draw target.
  -- lg.setColor(0, 0, 1, 1)
  -- lg.rectangle('line', self.targetX - 2, self.targetY - 2, 4, 4)
  lg.pop()
  lg.setScissor()
  lg.setCanvas()

  lg.push()
  lg.setColor(self.fadeTint, self.fadeTint, self.fadeTint, 1)
  lg.draw(self.canvas, 0, 0, 0, self.windowFactor)
  lg.pop()

  lg.push()
  lg.origin()

  lg.setColor(0, 0, 0, 0.4)
  local w, h = lg.getWidth(), lg.getHeight()
  lg.rectangle('fill', 0, h - 34, w, h)

  lg.setColor(1, 1, 1)
  lg.setFont(FontService.defaultFont)
  lg.print('FPS: ' .. love.timer.getFPS(), 0, h - 32)
  lg.print('Memory: ' .. math.floor(collectgarbage('count')) .. ' kb', 96, h - 32)

  lg.pop()

  -- lg.setColor(0, 1, 0, 1)
  -- lg.print(self.offsetX .. ' ' .. self.offsetY, 0, 0)
  -- lg.setColor(0, 0, 1, 1)
  -- lg.print(self.targetX .. ' ' .. self.targetY, 400, 0)
end

function Camera:addRail(rail)
  table.insert(self.rails, rail)
end

function Camera:onGobAdded(gob)
  if not gob:is(Player) then return end
  self.player = gob
end

function Camera:onGobRemoved(gob)
  if gob == self.player then
    self.player = nil
  end
end

function Camera:onGobsCleared()
  self.player = nil
end

function Camera:onStopCameraTracking()
  self.targetX, self.targetY = self.player.x, self.player.y
  self.player = nil
end

function Camera:onSetWindowFactor(windowFactor)
  self.windowFactor = windowFactor
end

function Camera:clearRails()
  lume.clear(self.rails)
  self.currentRail = nil
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

function Camera:fadeIn()
  self.fadeDelta = 1
end

function Camera:fadeOut()
  self.fadeDelta = -1
end

function Camera:isFadedIn()
  return self.fadeTint == 1
end

function Camera:isFadedOut()
  return self.fadeTint == 0
end


function Camera:__tostring()
  return 'Camera'
end

return Camera
