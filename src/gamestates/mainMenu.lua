local Gamestate = require 'gamestates.gamestate'

local MainMenu = Gamestate:extend()

function MainMenu:new(registry, eventBus)
  self.registry = registry
  self.eventBus = eventBus
end

function MainMenu:enter()
  log.debug('-------------')
  log.debug('  Main Menu')
  log.debug('-------------')

  local inWorld = self.parent:get('inWorld')
  -- Kick things off
  inWorld:startInitialSpawnScript('entrance.lua')
  self.parent:switch('inWorld')
end

return MainMenu
