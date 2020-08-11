local Component = require 'components.component'

local Animation = Component:extend()

function Animation:new(spriteAtlas)
  Animation.super.new(self)
  self.x, self.y = 0, 0
  self.rotation = 0
  self.scaleX, self.scaleY = 1, 1
  self.color = { r = 1, g = 1, b = 1, a = 1 }
  self.spriteAtlas = spriteAtlas
  self.current = nil
  self.oldCurrent = nil
  self.flippedH = false
  self.flippedV = false
  self.animations = {}
end

function Animation:add(name, animation)
  self.animations[name] = animation
  if not self.current then
    self.current = name
  end
end

function Animation:update(dt)
  Animation.super.new(self, dt)
  local animation = self.animations[self.current]
  if not animation then return end

  if self.oldCurrent ~= self.current then
    self.oldCurrent = self.current
    animation:gotoFrame(1)
  end

  animation:update(dt)
end

local lg = love.graphics

function Animation:draw()
  Animation.super.draw(self)
  local color = self.color
  lg.push()
  lg.setColor(color.r, color.g, color.b, color.a)
  local x, y = self.x + self.parent.x, self.y + self.parent.y
  local animation = self.animations[self.current]
  if not animation then return end

  animation.flippedH = self.flippedH
  animation.flippedV = self.flippedV
  local spriteAtlas = self.spriteAtlas
  local width, height = animation:getDimensions()
  animation:draw(
    spriteAtlas.image,
    x, y,
    self.rotation,
    self.scaleX, self.scaleY,
    math.floor(width / 2), math.floor(height / 2)
  )
  lg.pop()
end

return Animation
