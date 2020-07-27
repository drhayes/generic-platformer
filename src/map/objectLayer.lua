local Object = require 'lib.classic'
local SpriteSpec = require 'sprites.spriteSpec'

local ObjectLayer = Object:extend()

function ObjectLayer:new(layerData, tilesByGid, offsetX, offsetY, spriteMaker)
  offsetX, offsetY = offsetX or 0, offsetY or 0
  self.spriteMaker = spriteMaker
  self.name = layerData.name
  self.visible = layerData.visible or true
  self.opacity = layerData.opacity or 1
  self.properties = layerData.properties

  local sprites = {}
  self.sprites = sprites
  for i = 1, #layerData.objects do
    local object = layerData.objects[i]
    local objectType = tilesByGid[object.gid]
    local spriteSpec = SpriteSpec.fromMap(object, objectType)
    local sprite = spriteMaker:create(spriteSpec)
    if sprite then
      if sprite.pos then
        sprite.pos.x = sprite.pos.x + offsetX
        sprite.pos.y = sprite.pos.y + offsetY
      end

      table.insert(sprites, sprite)
    end
  end
end

function ObjectLayer:draw(windowFactor, tileAtlas)
  for i = 1, #self.sprites do
    local sprite = self.sprites[i]
    sprite:draw()
  end
end

return ObjectLayer
