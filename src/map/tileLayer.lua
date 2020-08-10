local GameObject = require 'gobs.gameObject'
local Grid = require 'core.grid'
local bit = bit or bit32 or require 'bit32' -- luacheck: ignore
local config = require 'gameConfig'

local FLIPPED_HORIZONTAL = 0x80000000
local FLIPPED_VERTICAL = 0x40000000
local FLIPPED_DIAGONALLY = 0x20000000
local TILE_SIZE = config.map.tileSize

local TileLayer = GameObject:extend()

local function basename(str)
  local name = string.gsub(str, "(.*/)(.*)", "%2")
  return name
end

function TileLayer:new(layerData, tilesByGid, offsetX, offsetY)
  TileLayer.super.new(self)
  offsetX, offsetY = offsetX or 0, offsetY or 0
  -- Check for that unruly "zstd" compression.
  if layerData.encoding ~= 'lua' then
    error('tilelayer not in lua encoding')
  end
  self.name = layerData.name
  self.visible = layerData.visible or true
  self.opacity = layerData.opacity or 1
  self.properties = layerData.properties
  self.layer = layerData.properties.layer or 'background'
  self.parallax = layerData.properties.parallax or 0
  self.width = 1
  self.height = 1

  local grid = Grid()
  self.grid = grid
  -- Iterate those chunks!
  for i = 1, #layerData.chunks do
    local chunk = layerData.chunks[i]
    -- Iterate the data taking into account the stride of the chunk.
    local width, height = chunk.width, chunk.height
    self.width = math.max(self.width, chunk.x * TILE_SIZE + offsetX + width * TILE_SIZE)
    self.height = math.max(self.height, chunk.y * TILE_SIZE + offsetY + height * TILE_SIZE)
    for y = 0, height - 1 do
      for x = 0, width - 1 do
        local tileIndex = 1 + y * width + x
        local tileGid = chunk.data[tileIndex]
        if tileGid ~= nil and tileGid ~= 0 then
          -- Check for horizontal flipping, vertical flipping, and rotation!
          local isFlippedHorizontal = bit.band(tileGid, FLIPPED_HORIZONTAL) ~= 0
          local isFlippedVertical = bit.band(tileGid, FLIPPED_VERTICAL) ~= 0
          local isFlippedDiagonal = bit.band(tileGid, FLIPPED_DIAGONALLY) ~= 0
          -- Mask out those high bits.
          tileGid = bit.band(tileGid, bit.bnot(
              bit.bor(FLIPPED_HORIZONTAL, bit.bor(
                FLIPPED_VERTICAL,
                FLIPPED_DIAGONALLY
              ))
            ))
          -- Grab tile type.
          local tileType = tilesByGid[tileGid]
          if not tileType then
            log.error('missing tile gid', tileGid)
          end
          local tileData = {
            image = basename(tileType.image),
            isFlippedHorizontal = isFlippedHorizontal,
            isFlippedVertical = isFlippedVertical,
            isFlippedDiagonal = isFlippedDiagonal,
            r = 0,
            sx = 1,
            sy = 1,
          }
          -- Are we flipped around and rotated?
          -- Shamelessly copied from: https://github.com/karai17/Simple-Tiled-Implementation/blob/master/sti/init.lua
          if isFlippedHorizontal then
            if isFlippedVertical and isFlippedDiagonal then
              tileData.r  = math.rad(-90)
              tileData.sy = -1
            elseif isFlippedVertical then
              tileData.sx = -1
              tileData.sy = -1
            elseif isFlippedDiagonal then
              tileData.r = math.rad(90)
            else
              tileData.sx = -1
            end
          elseif isFlippedVertical then
            if isFlippedDiagonal then
              tileData.r = math.rad(-90)
            else
              tileData.sy = -1
            end
          elseif isFlippedDiagonal then
            tileData.r  = math.rad(90)
            tileData.sy = -1
          end
          grid:set(
            x + chunk.x + math.floor(offsetX / TILE_SIZE),
            y + chunk.y + math.floor(offsetY / TILE_SIZE),
            tileData)
        end
      end
    end
  end
end

local lg = love.graphics

function TileLayer:initialize(eventBus, tileAtlas)
  local canvas = lg.newCanvas(self.width, self.height)
  lg.setCanvas(canvas)
  local tilesImage = tileAtlas.image
  local drawCell = function(x, y, tileData)
    local quad = tileAtlas:toQuad(tileData.image)
    local dx, dy = x * TILE_SIZE, y * TILE_SIZE
    if quad then
      lg.draw(tilesImage, quad, dx + 8, dy + 8, tileData.r, tileData.sx, tileData.sy, 8, 8)
    else
      log.error('missing tile image', tileData.image)
    end
  end
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.grid:forEach(drawCell)
  lg.pop()
  lg.setCanvas()
  self.canvas = canvas
end

function TileLayer:draw(offsetX, offsetY)
  TileLayer.super.draw(self)
  lg.push()
  lg.setColor(1, 1, 1, self.opacity)
  local dx = offsetX * self.parallax
  local dy = offsetY * self.parallax
  lg.draw(self.canvas, dx, dy, 0)
  lg.pop()
end

function TileLayer:__tostring()
  return 'TileLayer'
end

return TileLayer
