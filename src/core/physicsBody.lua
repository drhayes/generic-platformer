local Object = require 'lib.classic'
local Vector = require 'lib.brinevector'
local AABB = require 'core.aabb'
local bit = bit or bit32 or require 'bit32'

local PhysicsBody = Object:extend()

function PhysicsBody:new()
  -- This is the position of the entity, literally the same as the "pos" component
  -- for most entities.
  self.oldPosition = Vector()
  self.position = Vector()

  self.oldVelocity = Vector()
  self.velocity = Vector()
  self.maxVelocity = Vector()

  self.oldAcceleration = Vector()
  self.acceleration = Vector()

  self.friction = 1
  self.gravity = 0
  self.knockbackFactor = 1

  self.wasPushingLeftward = false
  self.isPushingLeftward = false

  self.wasPushingRightward = false
  self.isPushingRightward = false

  self.wasOnGround = true
  self.isOnGround = true

  self.isOnOneWayUpPlatform = false
  self.wasOnOneWayUpPlatform = false

  self.wasOnCeiling = false
  self.isOnCeiling = false

  -- I collide with things that match the mask.
  self.collisionMask = 0
  -- I'm in these collision layers.
  self.collisionLayers = 0
  -- What collided with me?
  self.collidedWith = nil

  -- This is the actual bounds of the physics body.
  self.aabb = AABB()
  -- This is how far it is offset from the self.position.
  self.aabbOffset = Vector()
end

-- Do I collide with this mask?
function PhysicsBody:collidesWith(mask)
  return bit.band(self.collisionMask, mask) ~= 0
end

-- Am I in this collision layer?
function PhysicsBody:inLayer(layerMask)
  return bit.band(self.collisionLayers, layerMask) ~= 0
end

function PhysicsBody:setVelocity(angle, speed)
  self.velocity.x = math.cos(angle) * speed
  self.velocity.y = math.sin(angle) * speed
end

function PhysicsBody:accelerate(angle, speed)
  self.acceleration = Vector.angled(Vector(speed, 0), angle)
end

return PhysicsBody
