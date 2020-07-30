local Object = require 'lib.classic'

local Animation = Object:extend()

function Animation:new(spriteAtlas)
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
  local animation = self.animations[self.current]
  if not animation then return end

  if self.oldCurrent ~= self.current then
    self.oldCurrent = self.current
    animation:gotoFrame(1)
  end

  animation:update(dt)
end

function Animation:draw(x, y, r, sx, sy, ox, oy, kx, ky)
  ox, oy = ox or 0, oy or 0
  local animation = self.animations[self.current]
  if not animation then return end

  animation.flippedH = self.flippedH
  animation.flippedV = self.flippedV
  local spriteAtlas = self.spriteAtlas
  local width, height = animation:getDimensions()
  ox = ox + math.floor(width / 2)
  oy = oy + math.floor(height / 2)
  animation:draw(spriteAtlas.image, x, y, r, sx, sy, ox, oy, kx, ky)
end

return Animation
