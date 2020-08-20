local Object = require 'lib.classic'

local Glimmer = require 'sprites.glimmer'
local GoldCoin = require 'sprites.goldCoin'
local LevelDoor = require 'sprites.levelDoor'
local Player = require 'sprites.player'
local SmallChest = require 'sprites.smallChest'
local Spawner = require 'sprites.spawner'

local SpriteMakerService = Object:extend()

function SpriteMakerService:new(eventBus, registry)
  self.eventBus = eventBus
  self.registry = registry

  self.mapping = {
    glimmer = Glimmer,
    goldCoin = GoldCoin,
    levelDoor = LevelDoor,
    player = Player,
    smallChest = SmallChest,
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
  spec.inputService = self.registry:get('input')
  spec.physicsService = self.registry:get('physics')
  spec.soundService = self.registry:get('sound')
  spec.particleService = self.registry:get('particles')

  return spriteClass(spec)
end

return SpriteMakerService
