local GameObject = require 'gobs.gameObject'

local lg = love.graphics

local Glimmer = GameObject:extend()

function Glimmer:new(spec)
  local x, y = spec.x, spec.y
  local width, height = spec.width, spec.height
  Glimmer.super.new(self, x, y)
  self.layer = 'default'
  self.width, self.height = width, height
  self.particles = self:add(spec.particleService:create('glimmer', 100))
  self.particles.x = width / 2
  self.particles.y = 0 --height / 8
  self.particles.blendMode = 'add'
  local ps = self.particles.ps
  ps:setEmissionArea('uniform', width / 2, height / 2)
  ps:setEmissionRate(10)

  ps:setSizes(1, 1)
  ps:setSizeVariation(1)
  ps:setColors(
    1, 1, 0, 0,
    1, 1, 1, 1,
    1, 0.9, 0.9, .5,
    1, 0.8, 0.8, .2,
    1, 0.7, 0.7, .1
  )
  ps:setParticleLifetime(0, 10)
  -- ps:setDirection(math.pi / 2)
  -- ps:setSpeed(2)
  ps:setLinearAcceleration(0, 10, 0, 20)
  ps:setLinearDamping(1, 2)

  ps:start()

  -- Make the gradient mesh.
  self.gradientMesh = lg.newMesh(
    {
      {0,0, 0,0, 1,1,.8,1},
      {width,0, 1,0, 1,1,.8,1},
      {width,height, 1,1, .5,.5,.8,0},
      {0,height, 0,1, .6,.6,.8,0}
    },
    'fan',
    'static'
  )
end

function Glimmer:draw()
  Glimmer.super.draw(self)
  lg.push()
  lg.setColor(1, 1, 1, 1)
  lg.draw(self.gradientMesh, self.x, self.y)
  lg.pop()
end

return Glimmer
