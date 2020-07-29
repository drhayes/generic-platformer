local Object = require 'lib.classic'
local lume = require 'lib.lume'

local SpriteSpec = Object:extend()

local id = 0

function SpriteSpec:new(spriteType)
  self.spriteType = spriteType
  self.name = ''
  self.id = id
  id = id + 1
  self.x = 0
  self.y = 0
  self.r = 0
  self.width = 16
  self.height = 16
  self.visible = true
  self.properties = {}
  self.spriteAtlas = nil
end

function SpriteSpec.fromMap(mapObject, objectType)
  local spec = SpriteSpec(objectType.type)
  spec.name = mapObject.name or ''
  spec.id = mapObject.id or id
  if spec.id == id then
    id = id + 1
  end
  spec.x = mapObject.x
  spec.y = mapObject.y
  spec.r = mapObject.rotation
  spec.width = mapObject.width or objectType.width
  spec.height = mapObject.height or objectType.height
  spec.visible = mapObject.visible
  spec.properties = lume.merge({}, objectType.properties or {}, mapObject.properties)
  return spec
end

return SpriteSpec
