local Object = require 'lib.classic'

local Player = require 'sprites.player'
local Spawner = require 'sprites.spawner'

local SpriteMakerService = Object:extend()

function SpriteMakerService:new(eventBus, registry)
  self.eventBus = eventBus
  self.registry = registry

  self.mapping = {
    player = Player,
    spawner = Spawner,
  }
end

function SpriteMakerService:create(spec)
  local spriteClass = self.mapping[spec.spriteType]
  if not spriteClass then
    log.warn('unknown sprite type', spec.spriteType)
    return nil
  end

  spec.eventBus = self.eventBus
  spec.animationService = self.registry:get('animation')
  spec.physicsService = self.registry:get('physics')

  return spriteClass(spec)
end

return SpriteMakerService
