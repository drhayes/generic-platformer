local Object = require 'lib.classic'
local PhysicsBody = require 'core.physicsBody'
local AABB = require 'core.aabb'

local PhysicsService = Object:extend()

function PhysicsService:new(eventBus)
  self.eventBus = eventBus

  self.bodies = {}
end

function PhysicsService:newBody()
  local callback = self:createCheckCollisionsCallback()
  local body = PhysicsBody(callback)
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
  for i = 1, #self.bodies do
    local body = self.bodies[i]
    -- Don't collide with yourself.
    if body ~= movingBody then
      local aabb = movingBody.aabb
      testAABB.center.x, testAABB.center.y = aabb.center.x + deltaX, aabb.center.y + deltaY
      if testAABB:overlaps(body.aabb) then
        return true
      end
    end
  end
  return false
end

return PhysicsService
