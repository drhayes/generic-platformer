local Gamestate = require 'gamestates.gamestate'
local Tilemap = require 'map.tilemap'
local TilemapSpec = require 'map.tilemapSpec'
local SpriteSpec = require 'sprites.spriteSpec'
local GobsList = require 'gobs.gobsList'

local InWorld = Gamestate:extend()

function InWorld:new(registry, eventBus)
  InWorld.super.new(self, registry, eventBus)

  self.gobs = GobsList(eventBus)
  self.tilemaps = {}

  -- TODO: Get rid of this event, probably.
  self:subscribe('addGob', self.onAddGob)
  self:subscribe('loadedTilemap', self.onLoadedTilemap)
  self:subscribe('setTileAtlas', self.onSetTileAtlas)
  self:subscribe('setWindowFactor', self.onSetWindowFactor)
  self:subscribe('spawnSpriteByType', self.onSpawnSpriteByType)
  self:subscribe('spawnSpriteBySpec', self.onSpawnSpriteBySpec)
  self:subscribe('switchCamera', self.onSwitchCamera)
  self:subscribe('switchLevels', self.onSwitchLevels)
end

function InWorld:enter()
  log.debug('-----------')
  log.debug('  InWorld')
  log.debug('-----------')
end

function InWorld:update(dt)
  self.gobs:update(dt)
  if not self.currentTilemap then
    self:switchTilemap('entrance.lua')
  end

  local inputService = self.registry:get('input')
  inputService:update(dt)
end

function InWorld:draw()
  if not self.camera then return end

  local camera = self.camera
  self.gobs:draw(
    camera.offsetX,
    camera.offsetY,
    camera.scale -- * self.windowFactor
  )

  if self.switchLevels then
    self.switchLevels = false
    self:switchTilemap(self.switchLevelName)
    self.eventBus:emit('spawnSpriteByType', 'player', self.switchPosX, self.switchPosY)
  end
end


function InWorld:onAddGob(gob)
  self.gobs:add(gob)
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

  self.gobs:clear()

  self.currentTilemap = tilemap
  local physicsService = self.registry:get('physics')
  tilemap:initialize(self.eventBus, self.tileAtlas, physicsService)
end

function InWorld:onSetTileAtlas(tileAtlas)
  self.tileAtlas = tileAtlas
end

function InWorld:onSetWindowFactor(windowFactor)
  self.windowFactor = windowFactor
end

function InWorld:onSpawnSpriteByType(spriteType, x, y)
  local spec = SpriteSpec(spriteType)
  spec.x, spec.y = x, y
  self:onSpawnSpriteBySpec(spec)
end

function InWorld:onSpawnSpriteBySpec(spec)
  local spriteMaker = self.registry:get('spriteMaker')
  local sprite = spriteMaker:create(spec)
  if not sprite then
    log.warn('did not get sprite back from spriteMaker', spec.spriteType, spec)
    return
  end
  self.eventBus:emit('addGob', sprite)
end

function InWorld:onSwitchCamera(camera)
  self.camera = camera
end

function InWorld:onSwitchLevels(levelName, posX, posY)
  self.switchLevels = true
  self.switchLevelName = levelName .. '.lua'
  self.switchPosX = posX
  self.switchPosY = posY
end

return InWorld
