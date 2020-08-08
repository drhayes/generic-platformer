local Object = require 'lib.classic'
local baton = require 'lib.baton'
local config = require 'gameConfig'
local lume = require 'lib.lume'

local InputService = Object:extend()

function InputService:new()
  local inputConfig = lume.clone(config.input.mappings)
  inputConfig.joystick = love.joystick.getJoysticks()[1]
  -- joystick = love.joystick.getJoysticks()[1],
  self.input = baton.new(inputConfig)
end

function InputService:update(dt)
  self.input:update(dt)
end

function InputService:get(control)
  return self.input:get(control)
end

function InputService:down(control)
  return self.input:down(control)
end

function InputService:pressed(control)
  return self.input:pressed(control)
end

function InputService:released(control)
  return self.input:released(control)
end

return InputService
