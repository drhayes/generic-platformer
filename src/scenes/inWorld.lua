local Scene = require 'scenes.scene'
local Tilemap = require 'map.tilemap'
local TilemapSpec = require 'map.tilemapSpec'
local SpriteSpec = require 'sprites.spriteSpec'
local GobsList = require 'gobs.gobsList'
local lume = require 'lib.lume'
local CoroutineList = require 'core.coroutineList'
local Player = require 'sprites.player'
local Spawner = require 'sprites.spawner'

local InWorld = Scene:extend()

function InWorld:new(registry, eventBus)
  InWorld.super.new(self, registry, eventBus)

  self.gobs = GobsList(eventBus)
  self.coroutines = CoroutineList()
  self.tilemaps = {}
  self.gobsById = {}
  self.checkpointSpecs = {}

  -- TODO: Get rid of this event, probably.
  self:subscribe('addGob', self.onAddGob)
  self:subscribe('gobAdded', self.onGobAdded)
  self:subscribe('loadedTilemap', self.onLoadedTilemap)
  self:subscribe('setTileAtlas', self.onSetTileAtlas)
  self:subscribe('spawnSpriteByType', self.onSpawnSpriteByType)
  self:subscribe('spawnSpriteBySpec', self.onSpawnSpriteBySpec)
  self:subscribe('startLevelExit', self.onStartLevelExit)
  self:subscribe('playerDead', self.onPlayerDead)
end

function InWorld:enter()
  log.debug('-----------')
  log.debug('  InWorld')
  log.debug('-----------')
end

function InWorld:update(dt)
  if self.camera then self.camera:update(dt) end
  self.gobs:update(dt)
  self.coroutines:update(dt)
  local inputService = self.registry:get('input')
  inputService:update(dt)
end

function InWorld:draw()
  if not self.camera then return end
  self.camera:draw(self.gobs)
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

function InWorld:onGobAdded(gob)
  if gob:is(Player) then
    self.player = gob
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
  tilemap:initialize(self.eventBus, self.tileAtlas, physicsService, self)
end

function InWorld:onSetTileAtlas(tileAtlas)
  self.tileAtlas = tileAtlas
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

function InWorld:onStartLevelExit(levelName, toId, offsetX, offsetY, playerWalksRight)
  self.coroutines:add(function(co, dt)
    local camera = self.camera
    co:wait(.5)
    camera:fadeOut()
    co:waitUntil(camera.isFadedOut, camera)
    co:wait(.2)
    self.switchLevels = true
    self.switchLevelName = levelName .. '.lua'
    self.switchToId = toId
    camera:fadeIn()
    coroutine.yield()
    local levelExit = self.gobsById[toId]
    if not levelExit then
      log.error('no level exit with id', toId)
      return
    end
    camera:lookAt(levelExit.x, levelExit.y)
    co:waitUntil(camera.isFadedIn, camera)
    local spriteMaker = self.registry:get('spriteMaker')
    local playerSpec = SpriteSpec('player')
    playerSpec.x, playerSpec.y = levelExit.x, levelExit.y
    playerSpec.x = playerSpec.x + offsetX
    playerSpec.y = playerSpec.y + offsetY
    local player = spriteMaker:create(playerSpec)
    player.levelExitCollider.enabled = false
    player.body.moveVelocity.x = playerWalksRight and 1 or -1
    player.stateMachine:switch('exitingLevelDoor')
    self.eventBus:emit('addGob', player)
    co:waitUntil(function() return player.body.moveVelocity.x == 0 end)
    player.stateMachine:switch('normal')
    player.levelExitCollider.enabled = true
    -- Find the spawner for this level and move it close to the exit we used.
    local spawner = self.gobs:findFirst(Spawner)
    if not spawner then
      log.error('could not find spawner in new level!')
      return
    end
    spawner.x = levelExit.x
    if playerWalksRight then
      spawner.x = spawner.x + 32
    else
      spawner.x = spawner.x - 32
    end
    spawner.y = levelExit.y - 48
  end)
end

function InWorld:startInitialSpawnScript(levelName)
  self.coroutines:add(function(co, dt)
    self:switchTilemap(levelName)
    local camera = self.camera
    camera:fadeIn()
    coroutine.yield()
    local spawner = self.gobs:findFirst(Spawner)
    if not spawner then
      log.error('could not find initial spawner')
      return
    end
    camera:lookAt(spawner.x, spawner.y)
    co:waitUntil(camera.isFadedIn, camera)
    co:wait(.5)
    self.eventBus:emit('spawnPlayer')
  end)
end

function InWorld:onPlayerDead(waitDelta)
  waitDelta = waitDelta or 0
  local checkpointService = self.registry:get('checkpoint')
  self.coroutines:add(function(co, dt)
    co:wait(2 + waitDelta)
    self.eventBus:emit('spawnPlayer')
    checkpointService:restore()
  end)
end

return InWorld
