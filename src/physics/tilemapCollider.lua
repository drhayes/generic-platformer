local Collider = require 'physics.collider'
local collisionLayers = require 'physics.collisionLayers'

local TINY_SCOOCH = 1e-4

local TilemapCollider = Collider:extend()

function TilemapCollider:collide(otherBody, collisionNormalX, collisionNormalY)
  if not otherBody:inLayer(collisionLayers.tilemap) then return false end

  local body = self.body
  local aabb = body.aabb
  local otherAABB = otherBody.aabb
  -- local shouldLog = self.body.parent and self.body.parent.isPlayer

  if collisionNormalY < 0 then
    -- if shouldLog then
    --   log.debug(body.position.x, math.abs(aabb.center.x - otherAABB.center.x), aabb.halfSize.x + otherAABB.halfSize.x, math.abs(aabb.center.x - otherAABB.center.x) >= aabb.halfSize.x + otherAABB.halfSize.x)
    --   log.debug(body.position.y, math.abs(aabb.center.y - otherAABB.center.y), aabb.halfSize.y + otherAABB.halfSize.y, math.abs(aabb.center.y - otherAABB.center.y) >= aabb.halfSize.y + otherAABB.halfSize.y)
    -- end
    body.position.y = otherAABB:top() - aabb.halfSize.y - body.aabbOffset.y - TINY_SCOOCH
    aabb.center.y = otherAABB:top() - aabb.halfSize.y - TINY_SCOOCH
    body.isOnGround = true
    body.fallingVelocity.y = 0
  elseif collisionNormalY > 0 then
    body.position.y = otherAABB:bottom() + aabb.halfSize.y - body.aabbOffset.y + TINY_SCOOCH
    aabb.center.y = otherAABB:bottom() + body.aabb.halfSize.y + TINY_SCOOCH
    body.isOnCeiling = true
    body.fallingVelocity.y = 0
  end

  if collisionNormalX < 0 then
    body.position.x = otherAABB:left() - aabb.halfSize.x - body.aabbOffset.x - TINY_SCOOCH
    aabb.center.x = otherAABB:left() - aabb.halfSize.x - TINY_SCOOCH
    body.isPushingRightward = true
    body.velocity.x = 0
  elseif collisionNormalX > 0 then
    body.position.x = otherAABB:right() + aabb.halfSize.x - body.aabbOffset.x + TINY_SCOOCH
    aabb.center.x = otherAABB:right() + aabb.halfSize.x + TINY_SCOOCH
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

  return true
end

return TilemapCollider
