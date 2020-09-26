local Scene = require 'scenes.scene'
local config = require 'gameConfig'
local CoroutineList = require 'core.coroutineList'

local Context = require 'ui.context'
local Frame = require 'ui.frame'
local bagLayout = require 'ui.bagLayout'
local fillLayout = require 'ui.fillLayout'
local Label = require 'ui.label'
local Button = require 'ui.button'

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
  local sound = self.registry:get('sound')

  local width, height = lg.getDimensions()
  self.context = Context(UI_SCALE)
  local rootFrame = self.context.rootFrame
  log.debug(height / 2)
  local menuFrame = rootFrame:add(Frame(0, 0, width / UI_SCALE / 3, height / UI_SCALE))
  menuFrame.layout = bagLayout(2, 2, 'vertical', 'center', true)

  local lessEvilRed = {
    r = .1,
    g = 0,
    b = 0,
    a = 1,
  }
  local evilRed = {
    r = 1,
    g = 0,
    b = 0,
    a = 1
  }

  local logoFrame = menuFrame:add(Frame(0, 0, 100, 100))
  local logoShadow = logoFrame:add(Label(titleFont, 'Surrender', 'center', 'middle', 0, 2, menuFrame.w))
  logoShadow:updateColor(evilRed)
  logoFrame:add(Label(titleFont, 'Surrender', 'center', 'middle', 0, 0, menuFrame.w))

  local choicesFrame = menuFrame:add(Frame(0, 0, width, 300))
  choicesFrame.layout = bagLayout(10, 2, 'vertical', 'center', true)

  local function createButton(text, handler, neighbor)
    local button = choicesFrame:add(Button(textFont, text, handler))
    button.fill.baseColor = lessEvilRed
    button.fill:initFocusColor(lessEvilRed, evilRed)
    button:on('trigger', sound.play, sound, 'success', 1)
    button:on('trigger', handler, self)
    button:on('focus', sound.play, sound, 'click', 1)
    if neighbor then
      button:setNeighbor('up', neighbor, true)
    end
    return button
  end
  local newGame = createButton('New Game', self.onNewGame)
  local options = createButton('Options', self.onOptions, newGame)
  local credits = createButton('Credits', self.onCredits, options)
  local quit = createButton('Quit', self.onQuit, credits)
  quit:setNeighbor('down', newGame, true)

  self.context:focus(newGame)

  self.isProcessingInput = true

  -- Kick things off
  self.inWorld = self.parent:get('inWorld')
  self.inWorld:startInitialSpawnScript(config.map.start)
end

function MainMenu:update(dt)
  self.inWorld:update(dt)
  self.coroutines:update(dt)
  self.context:update(dt)
  if not self.isProcessingInput then return end
  local input = self.registry:get('input')
  if input:pressed('up') then
    self.context:userInput('up')
  elseif input:pressed('down') then
    self.context:userInput('down')
  elseif input:pressed('left') then
    self.context:userInput('left')
  elseif input:pressed('right') then
    self.context:userInput('right')
  elseif input:pressed('jump') then
    self.context:userInput('trigger')
  elseif input:pressed('cancel') then
    self.context:userInput('cancel')
  end
end

function MainMenu:draw()
  self.inWorld:draw()
  self.context:draw()
end

function MainMenu:onNewGame()
  self.isProcessingInput = false
  self.coroutines:add(function(co)
    -- co:wait(7)
    self.parent:switch('inWorld')
    self.eventBus:emit('spawnPlayer')
  end)
end

function MainMenu:onOptions()
  log.debug('options')
end

function MainMenu:onCredits()
  log.debug('credits')
end

function MainMenu:onQuit()
  log.debug('quit')
end

return MainMenu
