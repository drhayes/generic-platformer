local Object = require('lib.classic')

local TilemapSpec = Object:extend()

function TilemapSpec:new(name, tilemapData)
  self.name = name
  self.tilemapData = tilemapData
end

return TilemapSpec
