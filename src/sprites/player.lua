local GameObject = require 'gobs.gameObject'
local Drawable = require 'gobs.drawable'

local HORIZ_VEL = 100

local Player = GameObject:extend()
-- TODO: Do I *need* drawable yet?
Player:implement(Drawable)

function Player:new(spec)
  self.x, self.y = spec.x, spec.y

  self.animation = spec.animationService:create('player')
  self.animation.current = 'idle'
  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 2
  body.aabb.halfSize.y = 5
  body.aabbOffset.y = 3
  body.friction = 0.95
  -- self.gravity = (2 * JUMP_HEIGHT) / math.pow(TIME_TO_JUMP_APEX, 2)
  -- self.jumpVelocity = self.gravity * TIME_TO_JUMP_APEX
  body.gravityForce.y = 50
  self.body = body
end

function Player:update(dt)
  if love.keyboard.isDown('right') then
    self.body.moveForce.x = HORIZ_VEL
  elseif love.keyboard.isDown('left') then
    self.body.moveForce.x = -HORIZ_VEL
  else
    self.body.moveForce.x = 0
  end

  self.animation:update(dt)
  self.body:update(dt)
  self.x = self.body.position.x
  self.y = self.body.position.y
end

local lg = love.graphics

function Player:draw()
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.animation:draw(self.x, self.y)
  lg.setColor(0, 1, 0, .3)
  lg.rectangle('fill', self.body.aabb:bounds())
  lg.pop()
end

function Player:__tostring()
  return 'Player'
end

return Player
