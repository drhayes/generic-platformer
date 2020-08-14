local Gamestate = require 'gamestates.gamestate'
local lily = require 'lib.lily'
local Atlas = require 'core.atlas'
local json = require 'lib.json'
local AnimationService = require 'services.animationService'
local SoundService = require 'services.soundService'

local PreloadGame = Gamestate:extend()

local lf = love.filesystem

local identity = function(x) return x end

local function doNewFont(filename)
  return lily.newFont(filename, 32)
end

local function doNewSound(sound)
  return lily.newSource(sound, 'static')
end

function PreloadGame:new(registry, eventBus)
  PreloadGame.super.new(self, registry, eventBus)
  self.images = {}
  self.jsons = {}
  self.tilemaps = {}
  self.fonts = {}
  self.sounds = {}
end

function PreloadGame:enter()
  log.debug('-----------')
  log.debug('  Preload')
  log.debug('-----------')

  self.resourceCount = 0

  self:slurpDirectory('media/images', self.images, lily.newImage)
  self:slurpDirectory('media/json', self.jsons, lily.read, json.parse)
  self:slurpDirectory('media/tilemaps', self.tilemaps, lily.read, loadstring)
  self:slurpDirectory('media/fonts', self.fonts, doNewFont)
  self:slurpDirectory('media/sfx', self.sounds, doNewSound)
end

function PreloadGame:slurpDirectory(directory, resourceTable, read, parse)
  read = read or lily.read
  parse = parse or identity
  local createHandler = function(name)
    self.resourceCount = self.resourceCount + 1
    return function(_, data)
      log.debug('Loaded:', name)
      resourceTable[name] = parse(data)
      self.resourceCount = self.resourceCount - 1
    end
  end
  local filenames = lf.getDirectoryItems(directory)
  for i = 1, #filenames do
    local filename = filenames[i]
    read(directory .. '/' .. filename)
      :onComplete(createHandler(filename))
  end
end

function PreloadGame:leave()
  -- Make the sprite atlas.
  local spriteAtlas = Atlas(self.jsons['sprites.json'], self.images['sprites.png'])
  self.eventBus:emit('setSpriteAtlas', spriteAtlas)

  -- Make the tile atlas.
  local tileAtlas = Atlas(self.jsons['tiles.json'], self.images['tiles.png'])
  self.eventBus:emit('setTileAtlas', tileAtlas)

  -- The tilemaps.
  for name, map in pairs(self.tilemaps) do
    self.eventBus:emit('loadedTilemap', name, map)
  end

  -- The fonts.
  for name, font in pairs(self.fonts) do
    love.graphics.setFont(font)
  end

  local registry = self.registry
  -- Gather the animation files and create an animation service.
  local animationJsons = {}
  for name, data in pairs(self.jsons) do
    if name:match('-animation.json') then
      animationJsons[name] = data
    end
  end
  local animationService = AnimationService(animationJsons, spriteAtlas)
  registry:add('animation', animationService)

  -- Gather the sounds and make a sound service.
  local soundService = SoundService()
  for name, sound in pairs(self.sounds) do
    soundService:add(name:gsub('.wav', ''), sound)
  end
  registry:add('sound', soundService)
end

function PreloadGame:update(dt)
  if self.resourceCount == 0 then
    self.parent:switch('inWorld')
  end
end

return PreloadGame
