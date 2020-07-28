local Gamestate = require 'gamestates.gamestate'
local Tilemap = require 'map.tilemap'
local SpriteMaker = require 'sprites.spriteMaker'
local TilemapSpec = require 'map.tilemapSpec'
local SpriteSpec = require 'sprites.spriteSpec'

local InWorld = Gamestate:extend()

function InWorld:new(registry, eventBus)
  InWorld.super.new(self, registry, eventBus)

  self.tilemaps = {}

  self:subscribe('loadedTilemap', self.onLoadedTilemap)
  self:subscribe('setTileAtlas', self.onSetTileAtlas)
  self:subscribe('setWindowFactor', self.onSetWindowFactor)
  self:subscribe('setSpriteAtlas', self.onSetSpriteAtlas)
  self:subscribe('spawnSprite', self.onSpawnSprite)
end

function InWorld:enter()
  log.debug('-----------')
  log.debug('  InWorld')
  log.debug('-----------')
end

function InWorld:update(dt)
  local gobsService = self.registry:get('gobs')
  gobsService:update(dt)
  if not self.currentTilemap then
    self:switchTilemap('entrance.lua')
  end
end

function InWorld:draw()
  local drawService = self.registry:get('draw')
  drawService:draw()
end


function InWorld:onLoadedTilemap(key, data)
  local rawTilemap = data()
  local tilemapSpec = TilemapSpec(key, rawTilemap)
  local tilemap = Tilemap(tilemapSpec)
  self.tilemaps[tilemap.name] = tilemap
end

function InWorld:switchTilemap(key)
  local tilemap = self.tilemaps[key]
  if not tilemap then
    log.warn('tried to switch to unknown tilemap', key)
    return
  end

  self.currentTilemap = tilemap
  tilemap:initialize(self.eventBus, self.spriteMaker, self.tileAtlas)
end

function InWorld:onSetTileAtlas(tileAtlas)
  self.tileAtlas = tileAtlas
end

function InWorld:onSetWindowFactor(windowFactor)
  self.windowFactor = windowFactor
end

function InWorld:onSetSpriteAtlas(spriteAtlas)
  self.spriteAtlas = spriteAtlas
  self.spriteMaker = SpriteMaker(spriteAtlas, self.eventBus)
end

function InWorld:onSpawnSprite(spriteType, x, y)
  if not self.spriteMaker then
    local mesg = 'Trying to spawn sprite before I have a spriteMaker'
    log.fatal(mesg, spriteType, x, y)
    error(mesg)
  end

  local spec = SpriteSpec(spriteType)
  spec.x, spec.y = x, y
  local sprite = self.spriteMaker:create(spec)
  if not sprite then
    log.warn('did not get sprite back from spriteMaker', spriteType, spec)
    return
  end
  self.eventBus:emit('addGob', sprite)
end

return InWorld
