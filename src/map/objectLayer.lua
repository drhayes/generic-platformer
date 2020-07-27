local Object = require 'lib.classic'
local SpriteSpec = require 'sprites.spriteSpec'
local lume = require 'lib.lume'

local ObjectLayer = Object:extend()

function ObjectLayer:new(layerData, tilesByGid, offsetX, offsetY)
  offsetX, offsetY = offsetX or 0, offsetY or 0
  self.name = layerData.name
  self.visible = layerData.visible or true
  self.opacity = layerData.opacity or 1
  self.properties = layerData.properties

  self.sprites = {}
  local spriteSpecs = {}
  self.spriteSpecs = spriteSpecs
  for i = 1, #layerData.objects do
    local object = layerData.objects[i]
    local objectType = tilesByGid[object.gid]
    local spriteSpec = SpriteSpec.fromMap(object, objectType)
    spriteSpec.x = spriteSpec.x + offsetX
    spriteSpec.y = spriteSpec.y + offsetY
    table.insert(spriteSpecs, spriteSpec)
  end
end

function ObjectLayer:initialize(eventBus, spriteMaker)
  lume.clear(self.sprites)
  local sprites = self.sprites
  for i = 1, #self.spriteSpecs do
    local spriteSpec = self.spriteSpecs[i]
    spriteSpec.eventBus = eventBus
    local sprite = spriteMaker:create(spriteSpec)
    if sprite then
      table.insert(sprites, sprite)
    end
  end
end

function ObjectLayer:update(dt)
  for i = 1, #self.sprites do
    local sprite = self.sprites[i]
    sprite:update(dt)
  end
end

function ObjectLayer:draw(windowFactor, tileAtlas)
  for i = 1, #self.sprites do
    local sprite = self.sprites[i]
    sprite:draw()
  end
end

return ObjectLayer
