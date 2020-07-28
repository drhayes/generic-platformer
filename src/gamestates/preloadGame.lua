local Gamestate = require 'gamestates.gamestate'
local lily = require 'lib.lily'
local Atlas = require 'core.atlas'
local json = require 'lib.json'

local PreloadGame = Gamestate:extend()

local lf = love.filesystem

local identity = function(x) return x end

function PreloadGame:new(registry, eventBus)
  PreloadGame.super.new(self, registry, eventBus)
  self.images = {}
  self.jsons = {}
  self.tilemaps = {}
end

function PreloadGame:enter()
  log.debug('-----------')
  log.debug('  Preload')
  log.debug('-----------')

  self.resourceCount = 0

  self:slurpDirectory('media/images', self.images, lily.newImage)
  self:slurpDirectory('media/json', self.jsons, lily.read, json.parse)
  self:slurpDirectory('media/tilemaps', self.tilemaps, lily.read, loadstring)
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
end

function PreloadGame:update(dt)
  if self.resourceCount == 0 then
    self.eventBus:emit('switchState', 'inWorld')
  end
end

return PreloadGame
