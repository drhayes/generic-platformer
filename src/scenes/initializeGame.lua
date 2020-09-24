local Scene = require 'scenes.scene'

local InitializeGame = Scene:extend()

function InitializeGame:enter()
  log.debug('--------------')
  log.debug('  Initialize')
  log.debug('--------------')

  self.parent:switch('preloadGame')
end

function InitializeGame:leave()
  -- From this point forward, no more globals.
  setmetatable(_G, {
    __index = function(_, var) error('Unknown variable '..var, 2) end,
    __newindex = function(_, var) error('New variable not allowed '..var, 2) end,
    __metatable = function(_) error('Global variable protection', 2) end,
  })
end

return InitializeGame
