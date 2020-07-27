-- Make some globals.
inspect = require 'lib.inspect' -- luacheck: ignore
log = require 'lib.log' -- luacheck: ignore
local config = require 'gameConfig'
local EventEmitter = require 'core.eventEmitter'
local StateSwitcher = require 'core.stateSwitcher'
local lily = require 'lib.lily'

local eventBus
local stateSwitcher

function love.load()
  log.level = 'debug' -- luacheck: ignore

  log.info('Starting Surrender...')

  -- Figure out a sensible windowFactor based on screen resolution.
  local _, _, flags = love.window.getMode()
  -- The window's flags contain the index of the monitor it's currently in.
  local width, height = love.window.getDesktopDimensions(flags.display) -- luacheck: ignore
  local wFactor, hFactor = width / config.graphics.width, height / config.graphics.height
  local windowFactor = math.min(math.floor(math.min(wFactor, hFactor)), config.graphics.maxWindowFactor)
  config.graphics.windowFactor = windowFactor
  -- Resize the window.
  love.window.setMode(windowFactor * config.graphics.width, windowFactor * config.graphics.height)

  -- Monkey-patch built-in random.
  math.random = love.math.random -- luacheck: ignore
  -- pixel art ftw
  love.graphics.setDefaultFilter('nearest','nearest', 1)
  love.graphics.setLineStyle('rough')
  -- GUI stuff.
  love.mouse.setVisible(false)

  eventBus = EventEmitter()
  stateSwitcher = StateSwitcher(eventBus)
  eventBus:emit('switchState', 'preloadGame')
end

function love.draw()
  stateSwitcher:draw()
end

function love.update(dt)
  stateSwitcher:update(dt)
end

function love.quit()
  lily.quit()
  log.info('Quitting Surrender. Have a blessed day.')
end
