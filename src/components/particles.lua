local Component = require 'components.component'

local Particles = Component:extend()

function Particles:new(ps)
  Particles.super.new(self)
  self.x, self.y = 0, 0
  self.ps = ps
end

function Particles:update(dt)
  self.ps:update(dt)
end

local lg = love.graphics

function Particles:draw()
  Particles.super.draw(self)
  lg.push()
  lg.setColor(1, 1, 1, 1)
  lg.draw(self.ps, self.x + self.parent.x, self.y + self.parent.y)
  lg.pop()
end


return Particles
