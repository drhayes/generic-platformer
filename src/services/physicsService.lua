local Object = require 'lib.classic'
local PhysicsBody = require 'physics.physicsBody'
local AABB = require 'core.aabb'
local TilemapCollider = require 'physics.tilemapCollider'

local PhysicsService = Object:extend()

-- local function collisionResolution(body) end

function PhysicsService:new(eventBus)
  self.eventBus = eventBus
  self.bodies = {}
end

-- TODO: Consider taking x, y, w, h, ox, oy here.
function PhysicsService:newBody(parent)
  local callback = self:createCheckCollisionsCallback()
  local body = PhysicsBody(parent, callback)
  table.insert(body.colliders, TilemapCollider(body))
  -- body.collisionResolution = collisionResolution
  table.insert(self.bodies, body)
  return body
end

function PhysicsService:createCheckCollisionsCallback()
  return function(body, deltaX, deltaY)
    return self:checkCollisions(body, deltaX, deltaY)
  end
end

local testAABB = AABB()
function PhysicsService:checkCollisions(movingBody, deltaX, deltaY)
  local result = false
  for i = 1, #self.bodies do
    local body = self.bodies[i]
    -- Don't collide with yourself.
    if body ~= movingBody then
      local aabb = movingBody.aabb
      testAABB.center.x, testAABB.center.y = aabb.center.x + deltaX, aabb.center.y + deltaY
      testAABB.halfSize.x, testAABB.halfSize.y = aabb.halfSize.x, aabb.halfSize.y
      if testAABB:overlaps(body.aabb) and movingBody:collidesWith(body.collisionLayers) then
        result = result or movingBody:runColliders(body, -deltaX, -deltaY)
        -- movingBody.collidedWith = body
        -- movingBody.collisionNormal.x = -deltaX
        -- movingBody.collisionNormal.y = -deltaY
      end
    end
  end
  return result
end

return PhysicsService
