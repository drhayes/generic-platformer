local Gamestate = require 'gamestates.gamestate'
local lily = require 'lib.lily'
local Atlas = require 'core.atlas'
local json = require 'lib.json'

local PreloadGame = Gamestate:extend()

local lf = love.filesystem

function PreloadGame:new(eventBus)
  PreloadGame.super.new(self, eventBus)
  self.images = {}
  self.jsons = {}
end

function PreloadGame:enter()
  log.info('Preload')
  self.resourceCount = 0
  -- Images.
  local imageFilenames = lf.getDirectoryItems('media/images')
  for i = 1, #imageFilenames do
    local imageName = imageFilenames[i]
    lily.newImage('media/images/' .. imageName)
      :onComplete(self:createImageHandler(imageName))
  end

  -- JSONs.
  local jsonFilenames = lf.getDirectoryItems('media/json')
  for i = 1, #jsonFilenames do
    local jsonFilename = jsonFilenames[i]
    lily.read('media/json/' .. jsonFilename)
      :onComplete(self:createJsonHandler(jsonFilename))
  end
end

function PreloadGame:leave()
  -- Make the tile atlas.
  local tileAtlas = Atlas(self.jsons['tiles.json'], self.images['tiles.png'])
  self.eventBus:emit('setTileAtlas', tileAtlas)
end

function PreloadGame:createImageHandler(imageName)
  self.resourceCount = self.resourceCount + 1
  return function(_, image)
    self.images[imageName] = image
    self.resourceCount = self.resourceCount - 1
  end
end

function PreloadGame:createJsonHandler(jsonName)
  self.resourceCount = self.resourceCount + 1
  return function(_, jsonData)
    self.jsons[jsonName] = json.parse(jsonData)
    self.resourceCount = self.resourceCount - 1
  end
end

function PreloadGame:update(dt)
  if self.resourceCount == 0 then
    self.eventBus:emit('switchState', 'inWorld')
  end
end

return PreloadGame
