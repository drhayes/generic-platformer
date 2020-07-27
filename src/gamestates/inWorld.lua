local Gamestate = require 'gamestates.gamestate'

local InWorld = Gamestate:extend()

function InWorld:enter()
  log.info('InWorld')
end

return InWorld
