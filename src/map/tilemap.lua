local Object = require 'lib.classic'
local TileLayer = require 'map.tileLayer'
local ObjectLayer = require 'map.objectLayer'

local Tilemap = Object:extend()


-- Returns a map of GID to tile thing.
local function parseTilesets(spec)
  local tilesByGid = {}
  local tilesetsByGid = {}
  for i = 1, #spec.tilesets do
    local tileset = spec.tilesets[i]
    for j = 1, #tileset.tiles do
      local tile = tileset.tiles[j]
      local gid = tileset.firstgid + tile.id
      tilesByGid[gid] = tile
      tilesetsByGid[gid] = tileset
    end
  end
  return tilesByGid, tilesetsByGid
end


function Tilemap:new(spec)
  self.name = spec.name
  self.spec = spec.tilemapData
  self.spriteMaker = spec.spriteMaker

  local tilesByGid = parseTilesets(self.spec)
  self.tilesByGid = tilesByGid

  -- Iterate layers to find top-left corner.
  local minX, minY = math.huge, math.huge
  for i = 1, #spec.tilemapData.layers do
    local layer = spec.tilemapData.layers[i]
    -- Is this a tilelayer?
    if layer.type == 'tilelayer' then
      -- Check every chunk.
      for j = 1, #layer.chunks do
        local chunk = layer.chunks[j]
        minX = math.min(minX, chunk.x)
        minY = math.min(minY, chunk.y)
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
    if layer.type == 'tilelayer' and layer.name ~= 'physics' then
      table.insert(layers, TileLayer(layer, tilesByGid, -minX, -minY))
    end
    if layer.type == 'objectgroup' then
      table.insert(layers, ObjectLayer(layer, tilesByGid, -minX, -minY, self.spriteMaker))
    end
  end
  self.layers = layers
end

function Tilemap:initialize(eventBus, spriteMaker)
  for i = 1, #self.layers do
    local layer = self.layers[i]
    layer:initialize(eventBus, spriteMaker)
  end
end

function Tilemap:update(dt)
  for i = 1, #self.layers do
    local layer = self.layers[i]
    layer:update(dt)
  end
end

function Tilemap:draw(windowFactor, tileAtlas)
  for i = 1, #self.layers do
    local layer = self.layers[i]
    layer:draw(windowFactor, tileAtlas)
  end
end

return Tilemap
