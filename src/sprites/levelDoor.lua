local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'

local LevelDoor = GameObject:extend()

function LevelDoor:new(spec)
  LevelDoor.super.new(self, spec.x, spec.y)
  self.levelName = spec.properties.levelName
  self.posX = spec.properties.posX
  self.posY = spec.properties.posY

  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x, body.aabb.halfSize.y = 11, 12
  body.collisionLayers = collisionLayers.levelExits
  self:add(body)

  self.eventBus = spec.eventBus
end

function LevelDoor:startLevelExit()
  if self.isAlreadyStarted then return end
  self.isAlreadyStarted = true
  self.eventBus:emit('startLevelExit', self.levelName, self.posX, self.posY)
end

function LevelDoor:__tostring()
  return 'LevelDoor'
end

return LevelDoor
