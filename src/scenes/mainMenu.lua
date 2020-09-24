local Scene = require 'scenes.scene'
local config = require 'gameConfig'

local MainMenu = Scene:extend()

function MainMenu:new(registry, eventBus)
  self.registry = registry
  self.eventBus = eventBus
end

function MainMenu:enter()
  log.debug('-------------')
  log.debug('  Main Menu')
  log.debug('-------------')

  -- Kick things off
  local inWorld = self.parent:switch('inWorld')
  inWorld:startInitialSpawnScript(config.map.start)
end

return MainMenu
