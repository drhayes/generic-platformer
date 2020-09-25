local Scene = require 'scenes.scene'
local config = require 'gameConfig'
local CoroutineList = require 'core.coroutineList'

local Context = require 'ui.context'
local Frame = require 'ui.frame'
local bagLayout = require 'ui.bagLayout'
local Label = require 'ui.label'

local lg = love.graphics

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
  local width, height = lg.getDimensions()
  self.context = Context(2)
  local rootFrame = self.context.rootFrame
  local menuFrame = rootFrame:add(Frame(0, 0, 200, height))

  local logoFrame = menuFrame:add(Frame(0, 0, 200, 120))
  logoFrame.layout = bagLayout(10, 10, 'vertical', 'middle')
  logoFrame:add(Label('Surrender'))

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
