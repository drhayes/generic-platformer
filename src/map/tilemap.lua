local Object = require 'lib.classic'
local TileLayer = require 'map.tileLayer'
local PhysicsLayer = require 'map.physicsLayer'
local SecretAreaLayer = require 'map.secretAreaLayer'
local SpriteSpec = require 'sprites.spriteSpec'
local config = require 'gameConfig'
local CameraLayer = require 'map.cameraLayer'

local TILE_SIZE = config.map.tileSize

local Tilemap = Object:extend()

-- Returns a map of GID to tile thing.
local function parseTilesets(spec)
  local tilesByGid = {}
  for i = 1, #spec.tilesets do
    local tileset = spec.tilesets[i]
    for j = 1, #tileset.tiles do
      local tile = tileset.tiles[j]
      local gid = tileset.firstgid + tile.id
      tilesByGid[gid] = tile
    end
  end
  return tilesByGid
end


function Tilemap:new(spec)
  self.name = spec.name
  self.spec = spec.tilemapData
  self.spriteSpecs = {}

  local tilesByGid = parseTilesets(self.spec)
  self.tilesByGid = tilesByGid

  -- Iterate layers to find top-left corner.
  -- Top corner is expressed in pixels, not map tiles.
  local minX, minY = math.huge, math.huge
  for i = 1, #spec.tilemapData.layers do
    local layer = spec.tilemapData.layers[i]
    -- Is this a tilelayer?
    if layer.type == 'tilelayer' then
      -- Check every chunk.
      for j = 1, #layer.chunks do
        local chunk = layer.chunks[j]
        minX = math.min(minX, chunk.x * TILE_SIZE)
        minY = math.min(minY, chunk.y * TILE_SIZE)
      end
    elseif layer.type == 'objectgroup' then
      for j = 1, #layer.objects do
        local object = layer.objects[j]
        minX = math.min(minX, object.x)
        minY = math.min(minY, object.y)
      end
    end
  end

  local layers = {}
  -- Now iterates layers to create Grid instances and add tile objects to in them.
  for i = 1, #spec.tilemapData.layers do
    local layer = spec.tilemapData.layers[i]
    if layer.type == 'tilelayer' and not layer.properties.isSecretArea then
      table.insert(layers, TileLayer(layer, tilesByGid, -minX, -minY))
    elseif layer.type == 'tilelayer' and layer.properties.isSecretArea then
      table.insert(layers, SecretAreaLayer(layer, tilesByGid, -minX, -minY))
    elseif layer.type == 'objectgroup' and layer.name == 'physics' then
      table.insert(layers, PhysicsLayer(layer, tilesByGid, -minX, -minY))
    elseif layer.type == 'objectgroup' and layer.name == 'camera' then
      table.insert(layers, CameraLayer(layer, -minX, -minY))
    elseif layer.name == 'sprites' then
      self:specSprites(layer, -minX, -minY)
    else
      log.error('unknown layer', layer.name, layer.type)
    end
  end
  self.layers = layers
end

function Tilemap:specSprites(spriteLayer, offsetX, offsetY)
  local spriteSpecs = self.spriteSpecs
  local tilesByGid = self.tilesByGid
  for i = 1, #spriteLayer.objects do
    local object = spriteLayer.objects[i]
    local objectType = tilesByGid[object.gid]
    local spriteSpec = SpriteSpec.fromMap(object, objectType)
    spriteSpec.x = spriteSpec.x + offsetX + object.width / 2
    spriteSpec.y = spriteSpec.y + offsetY + object.height / 2
    table.insert(spriteSpecs, spriteSpec)
  end
end

function Tilemap:initialize(eventBus, tileAtlas, physicsService)
  -- Do the layers.
  for i = 1, #self.layers do
    local layer = self.layers[i]
    layer:initialize(eventBus, tileAtlas, physicsService)
    if layer.update then
      eventBus:emit('addGob', layer)
    end
  end

  -- Do the sprites.
  for i = 1, #self.spriteSpecs do
    local spriteSpec = self.spriteSpecs[i]
    eventBus:emit('spawnSpriteBySpec', spriteSpec)
  end
end

return Tilemap
