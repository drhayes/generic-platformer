local Control = require 'ui.control'
local Label = require 'ui.label'
local EventEmitter = require 'core.eventEmitter'
local fillLayout = require 'ui.fillLayout'
local Fill = require 'ui.fill'

local Button = Control:extend()
Button:implement(EventEmitter)

function Button:new(font, text, x, y, w, h)
  self.font = font
  self.text = text
  w = w or (font:getWidth(text) + 20)
  h = h or (font:getHeight(text) + 2)
  Button.super.new(self, x, y, w or 40, h)
  self.layout = fillLayout(0)
  self.fill = self:add(Fill())
  self.label = self:add(Label(font, text, 'center', 'middle', 0, 0, w, h))
  self.label:setColor(1, 1, 1)
  self:updateLayout()
end

function Button:userInput(input)
  if input == 'trigger' then
    self:emit('trigger')
    return true
  end
  return Button.super.userInput(self, input)
end

function Button:onFocus()
  self.fill.isFocused = true
  self:emit('focus', self)
end

function Button:onBlur()
  self.fill.isFocused = false
  self:emit('blur', self)
end

function Button:__tostring()
  return 'Button'
end

return Button
