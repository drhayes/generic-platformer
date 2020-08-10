local GameObject = require 'gobs.gameObject'
local Player = require 'sprites.player'
local config = require 'gameConfig'
local AABB = require 'core.aabb'

local Camera = GameObject:extend()

function Camera:new(eventBus)
  Camera.super.new(self)
  self.eventBus = eventBus

  self.offsetX, self.offsetY, self.scale = 0, 0, 1
  self.regions = {}
  self.view = AABB(self.x, self.y, config.graphics.width, config.graphics.height)

  self.eventBus:on('gobAdded', self.onGobAdded, self)
end

function Camera:lookAt(x, y)
  self.view.center.x, self.view.center.y = x, y
  self.offsetX, self.offsetY = self.view:left(), self.view:top()
end

function Camera:update(dt)
  Camera.super.update(self, dt)
  local view = self.view
  local oldX, oldY = view.center.x, view.center.y

  if self.player then
    view.center.x, view.center.y = self.player.x, self.player.y
  end

  -- What region are we in?
  local currentRegion = nil
  for i = 1, #self.regions do
    local region = self.regions[i]
    if region:overlaps(view) then
      currentRegion = region
    end
  end

  if currentRegion then
    if view:left() < currentRegion:left() then
      view.center.x = currentRegion:left() + view.halfSize.x
    end
    if view:right() > currentRegion:right() then
      view.center.x = currentRegion:right() - view.halfSize.x
    end
    if view:top() < currentRegion:top() then
      view.center.y = currentRegion:top() + view.halfSize.y
    end
    if view:bottom() > currentRegion:bottom() then
      view.center.y = currentRegion:bottom() - view.halfSize.y
    end
  else
    -- No region? Give up and maintain.
    view.center.x, view.center.y = oldX, oldY
  end

  self.offsetX, self.offsetY = view:left(), view:top()
end

function Camera:addRegion(region)
  table.insert(self.regions, region)
end

function Camera:onGobAdded(gob)
  if not gob:is(Player) then return end
  self.player = gob
end

function Camera:__tostring()
  return 'Camera'
end

return Camera
