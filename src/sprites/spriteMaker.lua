local Object = require 'lib.classic'

local Spawner = require 'sprites.spawner'

local SpriteMaker = Object:extend()

function SpriteMaker:new(spriteAtlas)
  self.spriteAtlas = spriteAtlas

  self.mapping = {
    spawner = Spawner,
  }
end

function SpriteMaker:create(spec)
  local spriteClass = self.mapping[spec.spriteType]
  if not spriteClass then
    log.warn('unknown sprite type', spec.spriteType)
    return nil
  end

  return spriteClass(spec)
end

return SpriteMaker
