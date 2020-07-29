local GameObject = require 'gobs.gameObject'
local Drawable = require 'gobs.drawable'
local AABB = require 'core.aabb'
-- local Animation = require 'core.animation'

local Player = GameObject:extend()
Player:implement(Drawable)

function Player:new(spec)
  self.aabb = AABB(spec.x, spec.y, 16, 16)
  -- self.animation = Animation('player', spec.animationData)
end

function Player:update(dt)
  -- self.animation:update(dt)
end

local lg = love.graphics

function Player:draw()
  local aabb = self.aabb
  lg.push()
  lg.setColor(1, 1, 1, 1)
  lg.rectangle('fill', aabb:bounds())
  -- self.animation:draw(aabb.center.x, aabb.center.y)
  lg.pop()
end

function Player:__tostring()
  return 'Player'
end

return Player
