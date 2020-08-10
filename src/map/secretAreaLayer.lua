local TileLayer = require 'map.tileLayer'
local Player = require 'sprites.player'
local config = require 'gameConfig'
local Grid = require 'core.grid'

local TILE_SIZE = config.map.tileSize

local SecretAreaLayer = TileLayer:extend()

function SecretAreaLayer:new(layerData, tilesByGid, offsetX, offsetY)
  SecretAreaLayer.super.new(self, layerData, tilesByGid, offsetX, offsetY)
  self.layer = 'secretArea'
  self.opacity = 1
  self.isRevealing = false

  local revealGrid = Grid()
  self.revealGrid = revealGrid
  -- Find rectangular bounds within which I show myself.
  for i = 1, #layerData.chunks do
    local chunk = layerData.chunks[i]
    local width, height = chunk.width, chunk.height
    for y = 0, height - 1 do
      for x = 0, width - 1 do
        local tileIndex = 1 + y * width + x
        local tileGid = chunk.data[tileIndex]
        if tileGid ~= 0 then
          revealGrid:set(
            x + chunk.x + math.floor(offsetX / TILE_SIZE),
            y + chunk.y + math.floor(offsetY / TILE_SIZE),
            true
          )
        end
      end
    end
  end
end

function SecretAreaLayer:initialize(eventBus, tileAtlas)
  SecretAreaLayer.super.initialize(self, eventBus, tileAtlas)
  eventBus:on('gobAdded', self.onGobAdded, self)
end

function SecretAreaLayer:onGobAdded(sprite)
  if not sprite:is(Player) then return end
  self.player = sprite
end

function SecretAreaLayer:update(dt)
  if not self.player then
    self.opacity = 1
    return
  end

  local player = self.player
  local tileX, tileY = math.floor(player.x / TILE_SIZE), math.floor(player.y / TILE_SIZE)
  self.isRevealing = self.revealGrid:get(tileX, tileY)

  if self.isRevealing then
    self.opacity = math.max(0, self.opacity - dt * 5)
  else
    self.opacity = math.min(1, self.opacity + dt * 5)
  end
end


return SecretAreaLayer
