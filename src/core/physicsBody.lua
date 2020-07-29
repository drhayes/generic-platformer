local Object = require 'lib.classic'
local Vector = require 'lib.brinevector'
local AABB = require 'core.aabb'
local bit = bit or bit32 or require 'bit32'

local SUPERTINY = 1e-5

local PhysicsBody = Object:extend()

function PhysicsBody:new(checkCollisionsCallback)
  if not checkCollisionsCallback then
    local mesg = 'invalid physics body, no checkCollisions callback'
    log.fatal(mesg)
    error(mesg)
  end

  self.checkCollisions = checkCollisionsCallback

  -- This is the position of the entity, literally its x,y.
  self.oldPosition = Vector()
  self.position = Vector()

  self.oldVelocity = Vector()
  self.velocity = Vector()
  self.maxVelocity = Vector()

  self.oldAcceleration = Vector()
  self.acceleration = Vector()

  self.friction = 1
  self.knockbackFactor = 1

  self.gravityForce = Vector()
  self.moveForce = Vector()

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
  -- self.collisionMask = 0
  -- I'm in these collision layers.
  -- self.collisionLayers = 0
  -- What collided with me?
  -- self.collidedWith = nil

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

function PhysicsBody:update(dt)
  -- Store last frame's stuff.
  self.oldPosition.x, self.oldPosition.y = self.position.x, self.position.y
  self.oldVelocity.x, self.oldVelocity.y = self.velocity.x, self.velocity.y
  self.oldAcceleration.x, self.oldAcceleration.y = self.acceleration.x, self.acceleration.y
  self.wasPushingLeftward = self.isPushingLeftward
  self.wasPushingRightward = self.isPushingRightward
  self.wasOnGround = self.isOnGround
  self.wasOnCeiling = self.isOnCeiling
  self.wasOnOneWayUpPlatform = self.isOnOneWayUpPlatform
  self.isOnOneWayUpPlatform = false

  self.isOnGround = false
  self.isOnCeiling = false
  self.isPushingLeftward = false
  self.isPushingRightward = false

  -- Add our forces.
  self.velocity = self.velocity + self.gravityForce * dt
  self.velocity = self.velocity + self.moveForce * dt
  -- Accelerate our velocity.
  self.velocity = self.velocity + self.acceleration * dt

  -- Movement this frame.
  local deltaPos = self.velocity * dt

  if deltaPos.x ~= 0 or deltaPos.y ~= 0 then
    self:moveX(deltaPos.x)
    self:moveY(deltaPos.y)
  -- else
  --   -- Even if we don't move, check collisions.
  --   self:checkCollisions(0, 0)
  --   if body.collidedWith then
  --     self:resolveCollision(entity)
  --   end
  end

  self.velocity = self.velocity * self.friction
  self.aabb.center = self.position + self.aabbOffset
end

function PhysicsBody:moveX(amount)
  if math.abs(amount) < SUPERTINY then return end
  local sign = amount < 0 and -1 or 1
  while math.abs(amount) > 0 do
    local step = math.min(1, math.abs(amount)) * sign
    if not self:checkCollisions(step, 0) then
      self.position.x = self.position.x + step
      self.aabb.center.x = self.aabb.center.x + step
    else
      self.velocity.x = 0
      -- Done moving!
      return
    end
    amount = amount - step
  end
end

function PhysicsBody:moveY(amount)
  if math.abs(amount) < SUPERTINY then return end
  local sign = amount < 0 and -1 or 1
  while math.abs(amount) > 0 do
    local step = math.min(1, math.abs(amount)) * sign
    if not self:checkCollisions(0, step) then
      self.position.y = self.position.y + step
      self.aabb.center.y = self.aabb.center.y + step
    else
      self.velocity.y = 0
      -- Done moving!
      return
    end
    amount = amount - step
  end
end

return PhysicsBody
