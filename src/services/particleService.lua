local Object = require 'lib.classic'
local Particles = require 'components.particles'

local ParticleService = Object:extend()

function ParticleService:new(spriteAtlas)
  self.spriteAtlas = spriteAtlas
end

function ParticleService:create(imageRoot, buffer)
  local image = self.spriteAtlas.image
  local ps = love.graphics.newParticleSystem(image, buffer or 32)
  ps:setQuads(self.spriteAtlas:toQuad(imageRoot .. '-000.png'))
  ps:setOffset(0, 0)
  return Particles(ps)
end

return ParticleService
