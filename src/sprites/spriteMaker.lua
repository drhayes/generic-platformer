local Object = require 'lib.classic'

local Player = require 'sprites.player'
local Spawner = require 'sprites.spawner'

local SpriteMaker = Object:extend()

function SpriteMaker:new(spriteAtlas, eventBus)
  self.spriteAtlas = spriteAtlas
  self.eventBus = eventBus

  self.mapping = {
    player = Player,
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
