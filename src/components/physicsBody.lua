local Component = require 'components.component'
local Vector = require 'lib.brinevector'
local AABB = require 'core.aabb'
local bit = bit or bit32 or require 'bit32'

-- local SUPERTINY = 1e-5

local PhysicsBody = Component:extend()

local function no() return false end

function PhysicsBody:new(checkCollisionsCallback)
  PhysicsBody.super.new(self)
  self.checkCollisions = checkCollisionsCallback or no

  -- This is the position of the entity, literally its x,y.
  self.oldPosition = Vector()
  self.position = Vector()

  self.oldVelocity = Vector()
  self.velocity = Vector()
  -- self.maxVelocity = Vector()

  self.friction = 1
  self.knockbackFactor = 1

  self.gravityForce = Vector()

  self.fallingVelocity = Vector()
  self.jumpVelocity = Vector()
  self.moveVelocity = Vector()

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
  -- What objects are responsible for my collision response?
  self.colliders = {}
  self.resolutionType = 'stop'

  -- This is the actual bounds of the physics body.
  self.aabb = AABB()
  -- This is how far it is offset from the self.position.
  self.aabbOffset = Vector()
end

function PhysicsBody:addCollider(collider)
  collider.body = self
  table.insert(self.colliders, collider)
end

-- Do I collide with this mask?
function PhysicsBody:collidesWith(mask)
  return bit.band(self.collisionMask, mask) ~= 0
end

-- Am I in this collision layer?
function PhysicsBody:inLayer(layerMask)
  return bit.band(self.collisionLayers, layerMask) ~= 0
end

function PhysicsBody:runColliders(otherBody, collisionNormalX, collisionNormalY)
  local result = false
  for i = 1, #self.colliders do
    local collider = self.colliders[i]
    if collider:collide(otherBody, collisionNormalX, collisionNormalY) then
      result = true
    end
  end
  return result
end

function PhysicsBody:update(dt)
  PhysicsBody.super.update(self, dt)
  -- Store last frame's stuff.
  self.oldPosition.x, self.oldPosition.y = self.position.x, self.position.y
  self.oldVelocity.x, self.oldVelocity.y = self.velocity.x, self.velocity.y
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

  -- Are we jumping?
  if self.jumpVelocity.x ~= 0 then
    self.fallingVelocity.x = self.jumpVelocity.x
  end
  if self.jumpVelocity.y ~= 0 then
    self.fallingVelocity.y = self.jumpVelocity.y
  end

  -- Add our forces and velocities.
  self.fallingVelocity.x = self.fallingVelocity.x + self.gravityForce.x * dt
  self.fallingVelocity.y = self.fallingVelocity.y + self.gravityForce.y * dt
  -- Sum it all together.
  self.velocity.x = self.fallingVelocity.x + self.jumpVelocity.x + self.moveVelocity.x
  self.velocity.y = self.fallingVelocity.y + self.jumpVelocity.y + self.moveVelocity.y

  -- Movement this frame.
  local deltaX, deltaY = self.velocity.x * dt, self.velocity.y * dt

  if deltaX ~= 0 or deltaY ~= 0 then
    self:moveX(deltaX)
    self:moveY(deltaY)
  else
    -- Even if we don't move, check collisions.
    self:checkCollisions(0, 0)
  end

  self.velocity.x = self.velocity.x * self.friction
  self.velocity.y = self.velocity.y * self.friction
  self.aabb.center.x = self.position.x + self.aabbOffset.x
  self.aabb.center.y = self.position.y + self.aabbOffset.y

  if self.isOnGround then
    self.fallingVelocity.y = 0
  end

  self.parent.x, self.parent.y = self.position.x, self.position.y
end

function PhysicsBody:moveX(amount)
  -- if math.abs(amount) < SUPERTINY then return end
  local sign = amount < 0 and -1 or 1
  while math.abs(amount) > 0 do
    local step = math.min(1, math.abs(amount)) * sign
    if not self:checkCollisions(step, 0) then
      self.position.x = self.position.x + step
      self.aabb.center.x = self.aabb.center.x + step
    else
      -- Done moving!
      return
    end
    amount = amount - step
  end
end

function PhysicsBody:moveY(amount)
  -- if math.abs(amount) < SUPERTINY then return end
  local sign = amount < 0 and -1 or 1
  while math.abs(amount) > 0 do
    local step = math.min(1, math.abs(amount)) * sign
    if not self:checkCollisions(0, step) then
      self.position.y = self.position.y + step
      self.aabb.center.y = self.aabb.center.y + step
    else
      -- Done moving!
      return
    end
    amount = amount - step
  end
end

function PhysicsBody:collisionResolution() end

local lg = love.graphics

function PhysicsBody:debugDraw()
  lg.setColor(0, 1, 0, .3)
  lg.rectangle('fill', self.aabb:bounds())
end

return PhysicsBody
