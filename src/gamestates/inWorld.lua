local Gamestate = require 'gamestates.gamestate'
local Tilemap = require 'map.tilemap'
local TilemapSpec = require 'map.tilemapSpec'
local SpriteSpec = require 'sprites.spriteSpec'
local GobsList = require 'gobs.gobsList'
local config = require 'gameConfig'
local lume = require 'lib.lume'
local CoroutineList = require 'core.coroutineList'

local lg = love.graphics

local InWorld = Gamestate:extend()

function InWorld:new(registry, eventBus)
  InWorld.super.new(self, registry, eventBus)

  self.gobs = GobsList(eventBus)
  self.coroutines = CoroutineList()
  self.tilemaps = {}
  self.gobsById = {}

  -- TODO: Get rid of this event, probably.
  self:subscribe('addGob', self.onAddGob)
  self:subscribe('loadedTilemap', self.onLoadedTilemap)
  self:subscribe('setTileAtlas', self.onSetTileAtlas)
  self:subscribe('setWindowFactor', self.onSetWindowFactor)
  self:subscribe('spawnSpriteByType', self.onSpawnSpriteByType)
  self:subscribe('spawnSpriteBySpec', self.onSpawnSpriteBySpec)
  self:subscribe('switchCamera', self.onSwitchCamera)
  self:subscribe('startLevelExit', self.onStartLevelExit)
end

function InWorld:enter()
  log.debug('-----------')
  log.debug('  InWorld')
  log.debug('-----------')

  self.canvas = lg.newCanvas(config.graphics.width, config.graphics.height)
  self.fadeTint = 0
  self.fadeDelta = 1
end

function InWorld:update(dt)
  self.gobs:update(dt)
  self.coroutines:update(dt)
  local inputService = self.registry:get('input')
  inputService:update(dt)
  self.fadeTint = lume.clamp(self.fadeTint + self.fadeDelta * dt, 0, 1)
end

function InWorld:draw()
  if not self.camera then return end

  local camera = self.camera
  lg.setCanvas(self.canvas)
  lg.setScissor(0, 0, config.graphics.width, config.graphics.height)
  lg.clear()
  lg.push()
  lg.translate(-camera.offsetX, -camera.offsetY)
  self.gobs:draw()
  lg.setScissor()
  lg.pop()

  lg.setCanvas()
  lg.push()
  lg.setColor(self.fadeTint, self.fadeTint, self.fadeTint, 1)
  lg.draw(self.canvas, 0, 0, 0, self.windowFactor)
  lg.pop()

  if self.switchLevels then
    self.switchLevels = false
    self:switchTilemap(self.switchLevelName)
  end
end


function InWorld:onAddGob(gob)
  self.gobs:add(gob)
  if gob.id then
    self.gobsById[gob.id] = gob
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

  self.gobs:clear()
  lume.clear(self.gobsById)

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

function InWorld:onStartLevelExit(levelName, toId)
  self.coroutines:add(function(co, dt)
    co:wait(.5)
    self.fadeDelta = -1
    co:waitUntil(function() return self.fadeTint == 0 end)
    co:wait(.2)
    self.switchLevels = true
    self.switchLevelName = levelName .. '.lua'
    self.switchToId = toId
    self.fadeDelta = 1
    log.debug('fading in')
    co:waitUntil(function()
      return self.fadeTint == 1
    end)
    log.debug('looking for exit')
    local levelExit = self.gobsById[toId]
    log.debug(levelExit)
    if levelExit then
      log.debug('found exit')
      local spriteMaker = self.registry:get('spriteMaker')
      local playerSpec = SpriteSpec('player')
      playerSpec.x, playerSpec.y = levelExit.x, levelExit.y
      local player = spriteMaker:create(playerSpec)
      log.debug('about to spawn player')
      self.eventBus:emit('addGob', player)
    end
  end)
end

return InWorld
