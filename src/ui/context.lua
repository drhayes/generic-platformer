local Object = require 'lib.classic'
local Frame = require 'ui.frame'
-- local Confirm = require 'core.ui.confirm'
-- local Alert = require 'core.ui.alert'

local Context = Object:extend()

local lg = love.graphics

function Context:new(uiScale)
  self.uiScale = uiScale
  self.alpha = 1
  self.focused = nil
  local w, h = lg.getWidth() / self.uiScale, lg.getHeight() / self.uiScale
  self.rootFrame = Frame(0, 0, w, h)
  self.rootFrame.context = self
  self.w, self.h = w, h
  self.dialog = nil
  self.focusStack = {}
end

function Context:update(dt)
  self.rootFrame:update(dt)
  if self.dialog then
    self.dialog:update(dt)
  end
end

function Context:draw(alpha)
  alpha = alpha or 1
  lg.push()
  lg.scale(self.uiScale)
  self.rootFrame:draw(0, 0, alpha)
  if self.dialog then
    self.dialog:draw(0, 0, alpha)
  end
  lg.pop()
end

function Context:set(control)
  control.context = self
  if not self.focused then
    self:focus(control)
  end
  if control.children then
    for i = 1, #control.children do
      local child = control.children[i]
      if not child.context then
        self:set(child)
      end
    end
  end
end

function Context:processInput(input)
  if input:pressed('up') then
    self:userInput('up')
  elseif input:pressed('down') then
    self:userInput('down')
  elseif input:pressed('left') then
    self:userInput('left')
  elseif input:pressed('right') then
    self:userInput('right')
  elseif input:pressed('trigger') then
    self:userInput('trigger')
  elseif input:pressed('cancel') then
    self:userInput('cancel')
  elseif input:pressed('cycle-left') then
    self:userInput('cycle-left')
  elseif input:pressed('cycle-right') then
    self:userInput('cycle-right')
  elseif input:pressed('cancel') then
    self:userInput('cancel')
  end
end

function Context:userInput(input)
  if not self.focused then return end
  local handled, current = false, self.focused
  while not handled and current ~= nil do
    handled = current:userInput(input)
    if not handled then
      current = current.parent
    end
  end
end

function Context:focus(control)
  local focusChanged = self.focused ~= control
  if self.focused and focusChanged then
    self.focused:onBlur()
  end
  self.focused = control
  if self.focused and focusChanged then
    self.focused:onFocus()
  end
end

function Context:pushFocus(control)
  if self.focused then
    table.insert(self.focusStack, self.focused)
  end
  self:focus(control)
end

function Context:popFocus()
  local removed = table.remove(self.focusStack)
  self:focus(removed)
end


-- function Context:confirm(message, okText, cancelText, ...)
--   local confirm = Confirm(message, okText, cancelText, self.w, self.h)
--   confirm.context = self
--   confirm:on('cancel', self.onCloseDialog, self)
--   self.dialog = confirm
--   self:pushFocus(confirm)
--   return confirm
-- end

-- function Context:onCloseDialog()
--   if not self.dialog then return end
--   self.dialog:onClose()
--   self.dialog = nil
-- end

-- function Context:alert(title, message, okText)
--   local alert = Alert(title, message, okText, self.w / 3, self.h / 4, self.w / 3, self.h / 4)
--   alert.context = self
--   alert:on('ok', self.onCloseDialog, self)
--   self.dialog = alert
--   self:pushFocus(alert)
--   return alert
-- end

function Context:__tostring()
  return "Context"
end

return Context
