local Object = require 'lib.classic'
local Grid = require 'core.grid'
local config = require 'gameConfig'

local TILE_SIZE = config.map.tileSize

local PhysicsLayer = Object:extend()

function PhysicsLayer:new(layerData, tilesByGid, offsetX, offsetY)
  local grid = Grid()
  for i = 1, #layerData.chunks do
    local chunk = layerData.chunks[i]
    -- Iterate the data taking into account the stride of the chunk.
    local width, height = chunk.width, chunk.height
    for y = 0, height - 1 do
      for x = 0, width - 1 do
        local tileIndex = 1 + y * width + x
        local tileGid = chunk.data[tileIndex]
        if tileGid ~= 0 then
          -- Assume these are all solid tiles.
          grid:set(
            x + chunk.x + math.floor(offsetX / TILE_SIZE),
            y + chunk.y + math.floor(offsetY / TILE_SIZE),
            true)
        end
      end
    end
  end
  self.grid = grid
end

function PhysicsLayer:initialize(_, _, physicsService)
  local halfTile = math.floor(TILE_SIZE / 2)
  local setBody = function(x, y, data)
    if not data then return end
    local body = physicsService:newBody()
    local aabb = body.aabb
    aabb.center.x, aabb.center.y = x * TILE_SIZE + halfTile, y * TILE_SIZE + halfTile
    aabb.halfSize.x, aabb.halfSize.y = halfTile, halfTile
  end
  self.grid:forEach(setBody)
end

return PhysicsLayer
