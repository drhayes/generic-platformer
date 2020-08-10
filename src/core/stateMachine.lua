local Object = require 'lib.classic'

local StateMachine = Object:extend()

function StateMachine:new()
  self.states = {}
end

function StateMachine:add(state)
  self.states[getmetatable(state)] = state
  if not self.initial then
    self.initial = state
  end
end

function StateMachine:update(dt)
  if not self.current then
    self.current = self.initial
    self.current:enter()
  end
  local transitionTo = self.current:update(dt)
  if transitionTo then
    local nextState = self.states[transitionTo]
    if nextState then
      local oldState = self.current
      oldState:leave()
      self.current = nextState
      self.current:enter()
    else
      self.current = nil
    end
  end
end

function StateMachine:draw()
  if not self.current then return end
  self.current:draw()
end

return StateMachine
