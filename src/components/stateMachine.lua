local Component = require 'components.component'

local StateMachine = Component:extend()

function StateMachine:new()
  StateMachine.super.new(self)
  self.states = {}
end

function StateMachine:add(name, state)
  self.states[name] = state
  if not self.initial then
    self.initial = state
  end
end

function StateMachine:update(dt)
  StateMachine.super.update(self, dt)

  if not self.current then
    self.current = self.initial
    self.current:enter()
  end

  local transitionTo = self.current:update(dt)
  if transitionTo then
    local nextState = self.states[transitionTo]
    if nextState then
      self.current:leave()
      self.current = nextState
      self.current:enter()
    end
  end
end

function StateMachine:draw()
  StateMachine.super.draw(self)
  if not self.current then return end
  self.current:draw()
end

return StateMachine
