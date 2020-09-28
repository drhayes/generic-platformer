local Component = require 'components.component'
local Vector = require 'lib.brinevector'
local AABB = require 'core.aabb'
local bit = bit or require 'bit32'
local lume = require 'lib.lume'

local PhysicsBody = Component:extend()

local function no() return false end

function PhysicsBody:new(checkCollisionsCallback)
  PhysicsBody.super.new(self)
  self.checkCollisions = checkCollisionsCallback or no

  -- This is the position of the entity, literally its x,y.
  self.oldPosition = Vector()
  self.position = Vector()

  -- Used in whole-pixel movement code.
  self.remainderX = 0
  self.remainderY = 0

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

  self.wasOnGround = false
  self.isOnGround = false

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
  return collider
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
    if collider.enabled and collider:collide(otherBody, collisionNormalX, collisionNormalY) then
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

  -- Did we move at all? If not, and we were already on the ground, we still are.
  if self.position.y - self.oldPosition.y == 0 and self.wasOnGround and not self.isOnGround then
    self.isOnGround = true
  end

  self.parent.x, self.parent.y = self.position.x, self.position.y
end

function PhysicsBody:moveX(amount)
  self.remainderX = self.remainderX + amount
  local move = lume.round(amount)
  if move == 0 then return end

  self.remainderX = self.remainderX - move
  local sign = move < 0 and -1 or 1
  while move ~= 0 do
    if not self:checkCollisions(sign, 0) then
      self.position.x = self.position.x + sign
      self.aabb.center.x = self.aabb.center.x + sign
    else
      -- Done moving!
      return
    end
    move = move - sign
  end
end

function PhysicsBody:moveY(amount)
  self.remainderY = self.remainderY + amount
  local move = lume.round(amount)
  if move == 0 then return end

  self.remainderY = self.remainderY - move
  local sign = move < 0 and -1 or 1
  while move ~= 0 do
    if not self:checkCollisions(0, sign) then
      self.position.y = self.position.y + sign
      self.aabb.center.y = self.aabb.center.y + sign
    else
      -- Done moving!
      return
    end
    move = move - sign
  end
end

function PhysicsBody:collisionResolution() end

local lg = love.graphics

function PhysicsBody:debugDraw()
  lg.setColor(0, 1, 0, .3)
  lg.rectangle('fill', self.aabb:bounds())
end

function PhysicsBody:__tostring()
  return 'PhysicsBody'
end

return PhysicsBody
