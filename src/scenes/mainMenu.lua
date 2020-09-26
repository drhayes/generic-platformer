local Scene = require 'scenes.scene'
local config = require 'gameConfig'
local CoroutineList = require 'core.coroutineList'

local Context = require 'ui.context'
local Frame = require 'ui.frame'
local bagLayout = require 'ui.bagLayout'
local fillLayout = require 'ui.fillLayout'
local Label = require 'ui.label'

local lg = love.graphics
local UI_SCALE = 2

local MainMenu = Scene:extend()

function MainMenu:new(registry, eventBus)
  self.registry = registry
  self.eventBus = eventBus
  self.coroutines = CoroutineList()

end

function MainMenu:enter()
  log.debug('-------------')
  log.debug('  Main Menu')
  log.debug('-------------')

  -- The UI.
  local fonts = self.registry:get('fonts')
  local titleFont = fonts:get('title')
  local textFont = fonts:get('text')

  local width, height = lg.getDimensions()
  self.context = Context(UI_SCALE)
  local rootFrame = self.context.rootFrame
  log.debug(height / 2)
  local menuFrame = rootFrame:add(Frame(0, 0, width / UI_SCALE / 3, height / UI_SCALE))
  menuFrame.layout = bagLayout(2, 2, 'vertical', 'center', true)

  local logoFrame = menuFrame:add(Frame(0, 0, 100, 100))
  logoFrame.layout = fillLayout()
  logoFrame:add(Label(titleFont, 'Surrender', 'center'))

  local choicesFrame = menuFrame:add(Frame(0, 0, width, 300))
  choicesFrame.layout = bagLayout(10, 2, 'vertical', 'center', true)
  choicesFrame:add(Label(textFont, 'Hey'))
  choicesFrame:add(Label(textFont, 'Hey'))
  choicesFrame:add(Label(textFont, 'Hey'))
  choicesFrame:add(Label(textFont, 'Hey'))

  -- Kick things off
  self.inWorld = self.parent:get('inWorld')
  self.inWorld:startInitialSpawnScript(config.map.start)

  -- self.coroutines:add(function(co)
  --   co:wait(7)
  --   self.parent:switch('inWorld')
  --   self.eventBus:emit('spawnPlayer')
  -- end)
end

function MainMenu:update(dt)
  self.inWorld:update(dt)
  self.coroutines:update(dt)
  self.context:update(dt)
end

function MainMenu:draw()
  self.inWorld:draw()

  self.context:draw()

  -- lg.push()
  -- lg.setColor(1, 0, 0, 1)
  -- lg.print('Surrender',
  --   self.width / 6,
  --   self.height / 4,
  --   0,
  --   3)
  -- lg.pop()
end

return MainMenu
