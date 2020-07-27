local Object = require 'lib.classic'
local InWorld = require 'gamestates.inWorld'
local PreloadGame = require 'gamestates.preloadGame'

local StateSwitcher = Object:extend()

function StateSwitcher:new(eventBus)
  self.eventBus = eventBus
  self.states = {
    inWorld = InWorld(eventBus),
    preloadGame = PreloadGame(eventBus),
  }
  self.currentState = nil

  self.eventBus:on('switchState', self.onSwitchState, self)
end

function StateSwitcher:onSwitchState(newStateName)
  local newState = self.states[newStateName]
  if not newState then
    log.error('Bad state name', newStateName)
    return
  end

  if self.currentState then
    self.currentState:leave()
  end
  self.currentState = newState
  self.currentState:enter()
end

function StateSwitcher:update(dt)
  self.currentState:update(dt)
end

function StateSwitcher:draw()
  self.currentState:draw()
end

return StateSwitcher
