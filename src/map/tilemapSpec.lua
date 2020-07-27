local Object = require('lib.classic')

local TilemapSpec = Object:extend()

function TilemapSpec:new(name, tilemapData, spriteMaker)
  self.name = name
  self.tilemapData = tilemapData
  self.spriteMaker = spriteMaker
end

return TilemapSpec
