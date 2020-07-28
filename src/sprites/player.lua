local GameObject = require 'gobs.gameObject'
local Drawable = require 'gobs.drawable'
local AABB = require 'core.aabb'

local Player = GameObject:extend()
Player:implement(Drawable)

function Player:new(spec)
  self.aabb = AABB(spec.x, spec.y, 16, 16)
end

local lg = love.graphics

function Player:draw()
  local aabb = self.aabb
  lg.push()
  lg.setColor(1, 1, 1, 1)
  lg.rectangle('fill', aabb:bounds())
  lg.pop()
end

return Player
