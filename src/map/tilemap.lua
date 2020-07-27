local Object = require 'lib.classic'
local TilemapLayer = require 'map.tilemapLayer'

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


function Tilemap:new(name, spec)
  self.name = name
  self.spec = spec

  local tilesByGid = parseTilesets(self.spec)
  self.tilesByGid = tilesByGid

  -- Iterate layers to find top-left corner.
  local minX, minY = math.huge, math.huge
  for i = 1, #spec.layers do
    local layer = spec.layers[i]
    -- Check every chunk.
    for j = 1, #layer.chunks do
      local chunk = layer.chunks[j]
      minX = math.min(minX, chunk.x)
      minY = math.min(minY, chunk.y)
    end
  end

  local layers = {}
  -- Now iterates layers to create Grid instances and add tile objects to in them.
  for i = 1, #spec.layers do
    local layer = spec.layers[i]
    if layer.type == 'tilelayer' and layer.name ~= 'physics' then
      table.insert(layers, TilemapLayer(layer, tilesByGid, -minX, -minY))
    end
  end
  self.layers = layers
end

function Tilemap:draw(windowFactor, tileAtlas)
  for i = 1, #self.layers do
    local layer = self.layers[i]
    layer:draw(windowFactor, tileAtlas)
  end
end

return Tilemap
