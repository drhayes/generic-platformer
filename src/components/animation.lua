local Component = require 'components.component'

local Animation = Component:extend()

function Animation:new(spriteAtlas)
  Animation.super.new(self)
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

-- function Animation:draw(x, y, r, sx, sy, ox, oy, kx, ky)
function Animation:draw(offsetX, offsetY, scale, alpha)
  Animation.super.draw(self)
  lg.push()
  lg.setColor(1, 1, 1, 1)
  local ox, oy = self.parent.x, self.parent.y
  local animation = self.animations[self.current]
  if not animation then return end

  animation.flippedH = self.flippedH
  animation.flippedV = self.flippedV
  local spriteAtlas = self.spriteAtlas
  local width, height = animation:getDimensions()
  -- ox = ox - math.floor(width / 2)
  -- oy = oy - math.floor(height / 2)
  -- animation:draw(spriteAtlas.image, x, y, r, sx, sy, ox, oy, kx, ky)
  animation:draw(spriteAtlas.image, ox, oy, 0, 1, 1, math.floor(width / 2), math.floor(height / 2))
  lg.pop()
end

return Animation
