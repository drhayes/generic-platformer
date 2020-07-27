local Gamestate = require 'gamestates.gamestate'
local Tilemap = require 'map.tilemap'
local SpriteMaker = require 'sprites.spriteMaker'

local InWorld = Gamestate:extend()

function InWorld:new(eventBus)
  InWorld.super.new(self, eventBus)

  self.eventBus:on('loadedTilemap', self.onLoadedTilemap, self)
  self.eventBus:on('setTileAtlas', self.onSetTileAtlas, self)
  self.eventBus:on('setWindowFactor', self.onSetWindowFactor, self)
  self.eventBus:on('setSpriteAtlas', self.onSetSpriteAtlas, self)
end

function InWorld:enter()
  log.info('InWorld')
end

function InWorld:draw()
  if self.currentTilemap then
    self.currentTilemap:draw(self.windowFactor, self.tileAtlas)
  end
end


function InWorld:onLoadedTilemap(key, data)
  local rawTilemap = data()
  local tilemap = Tilemap(key, rawTilemap, self.spriteMaker)

  if not self.currentTilemap then
    self.currentTilemap = tilemap
  end
end

function InWorld:onSetTileAtlas(tileAtlas)
  self.tileAtlas = tileAtlas
end

function InWorld:onSetWindowFactor(windowFactor)
  self.windowFactor = windowFactor
end

function InWorld:onSetSpriteAtlas(spriteAtlas)
  self.spriteAtlas = spriteAtlas
  self.spriteMaker = SpriteMaker(spriteAtlas)
end

return InWorld
