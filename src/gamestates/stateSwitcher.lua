local Object = require 'lib.classic'

local StateSwitcher = Object:extend()

function StateSwitcher:new()
  self.states = {}
  self.currentState = nil
end

function StateSwitcher:add(name, gamestate)
  self.states[name] = gamestate
  gamestate.parent = self
  return gamestate
end

function StateSwitcher:get(name)
  local state = self.states[name]
  if not state then
    log.warn('tried to get nonexistent state', name)
  end
  return state
end

function StateSwitcher:switch(newStateName)
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
