local Gamestate = require 'gamestates.gamestate'
local Tilemap = require 'map.tilemap'
local SpriteMaker = require 'sprites.spriteMaker'
local TilemapSpec = require 'map.tilemapSpec'

local InWorld = Gamestate:extend()

function InWorld:new(eventBus)
  InWorld.super.new(self, eventBus)

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
  if self.currentTilemap then
    self.currentTilemap:update(dt)
  end
  if not self.currentTilemap then
    self:switchTilemap('entrance.lua')
  end
end

function InWorld:draw()
  if self.currentTilemap then
    self.currentTilemap:draw(self.windowFactor, self.tileAtlas)
  end
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
  tilemap:initialize(self.eventBus, self.spriteMaker)
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
  log.debug('spawn sprite', spriteType, x, y)
  -- How to hook up this to where the sprites are drawing in the tilemap?
  -- Given a sprite type and an x,y, what layer does that sprite come in at?
end

return InWorld
