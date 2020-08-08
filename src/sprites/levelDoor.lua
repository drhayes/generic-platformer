local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'

local LevelDoor = GameObject:extend()

function LevelDoor:new(spec)
  self.x, self.y = spec.x, spec.y

  local body = spec.physicsService:newBody(self)
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x, body.aabb.halfSize.y = 11, 12
  body.collisionLayers = collisionLayers.usables
  self.body = body
end

function LevelDoor:update(dt)
  self.body:update(dt)
end

local lg = love.graphics

function LevelDoor:draw()
  lg.push()
  lg.setColor(0, 1, 0, .3)
  lg.rectangle('fill', self.body.aabb:bounds())
  lg.pop()
end

return LevelDoor
