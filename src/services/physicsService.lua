local Object = require 'lib.classic'
local PhysicsBody = require 'core.physicsBody'
local AABB = require 'core.aabb'
local collisionLayers = require 'core.collisionLayers'

local PhysicsService = Object:extend()

local function collisionResolution(body)
  if body.collidedWith:inLayer(collisionLayers.tilemap) then
    local collidedWith = body.collidedWith
    local aabb = body.aabb
    local collidedAABB = collidedWith.aabb
    if body.collisionNormal.y < 0 then
      body.position.y = collidedAABB:top() - aabb.halfSize.y - body.aabbOffset.y
      aabb.center.y = collidedAABB:top() - aabb.halfSize.y
      body.isOnGround = true
      body.fallingVelocity.y = 0
    elseif body.collisionNormal.y > 0 then
      body.position.y = collidedAABB:bottom() + aabb.halfSize.y - body.aabbOffset.y
      aabb.center.y = collidedAABB:bottom() + body.aabb.halfSize.y
      body.isOnCeiling = true
      body.fallingVelocity.y = 0
    end
    if body.collisionNormal.x < 0 then
      body.position.x = collidedAABB:left() - aabb.halfSize.x - body.aabbOffset.x
      aabb.center.x = collidedAABB:left() - aabb.halfSize.x
      body.isPushingRightward = true
      body.velocity.x = 0
    elseif body.collisionNormal.x > 0 then
      body.position.x = collidedAABB:right() + aabb.halfSize.x - body.aabbOffset.x
      aabb.center.x = collidedAABB:right() + aabb.halfSize.x
      body.isPushingLeftward = true
      body.velocity.x = 0
    end

    if body.resolutionType == 'freeze' then
      body.fallingVelocity.x = 0
      body.fallingVelocity.y = 0
      body.resolutionType = 'stop'
    end

    if body.resolutionType == 'bounceOnce' then
      body.fallingVelocity.y = -body.oldVelocity.y * .7
      body.isOnGround = false
      body.resolutionType = 'freeze'
    end
  end
end

function PhysicsService:new(eventBus)
  self.eventBus = eventBus
  self.bodies = {}
end

-- TODO: Consider taking x, y, w, h, ox, oy here.
function PhysicsService:newBody()
  local callback = self:createCheckCollisionsCallback()
  local body = PhysicsBody(callback)
  body.collisionResolution = collisionResolution
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
      testAABB.halfSize.x, testAABB.halfSize.y = aabb.halfSize.x, aabb.halfSize.y
      if testAABB:overlaps(body.aabb) and movingBody:collidesWith(body.collisionLayers) then
        movingBody.collidedWith = body
        movingBody.collisionNormal.x = -deltaX
        movingBody.collisionNormal.y = -deltaY
        return true
      end
    end
  end
  return false
end

return PhysicsService
