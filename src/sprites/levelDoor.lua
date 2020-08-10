local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'

local LevelDoor = GameObject:extend()

function LevelDoor:new(spec)
  LevelDoor.super.new(self)
  self.x, self.y = spec.x, spec.y
  self.levelName = spec.properties.levelName
  self.posX = spec.properties.posX
  self.posY = spec.properties.posY

  local body = spec.physicsService:newBody(self)
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x, body.aabb.halfSize.y = 11, 12
  body.collisionLayers = collisionLayers.usables
  self.body = body
  self:add(self.body)

  self.isUsable = true

  self.eventBus = spec.eventBus
end

function LevelDoor:used(user)
  self.eventBus:emit('switchLevels', self.levelName, self.posX, self.posY)
end

function LevelDoor:__tostring()
  return 'LevelDoor'
end

return LevelDoor
