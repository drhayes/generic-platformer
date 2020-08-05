-- Make some globals.
inspect = require 'lib.inspect' -- luacheck: ignore
log = require 'lib.log' -- luacheck: ignore
local config = require 'gameConfig'
local EventEmitter = require 'core.eventEmitter'
local StateSwitcher = require 'gamestates.stateSwitcher'
local lily = require 'lib.lily'

local Registry = require 'services.registry'
local DrawService = require 'services.drawService'
local GobsService = require 'services.gobsService'
local InputService = require 'services.inputService'
local SpriteMaker = require 'services.spriteMakerService'
local PhysicsService = require 'services.physicsService'


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
  -- Resize the window.
  love.window.setMode(windowFactor * config.graphics.width, windowFactor * config.graphics.height)

  -- Monkey-patch built-in random.
  math.random = love.math.random -- luacheck: ignore
  -- pixel art ftw
  love.graphics.setDefaultFilter('nearest','nearest', 1)
  love.graphics.setLineStyle('rough')
  -- GUI stuff.
  love.mouse.setVisible(false)

  local eventBus = EventEmitter()

  local registry = Registry()
  registry:add('gobs', GobsService(eventBus))
  registry:add('draw', DrawService(eventBus, windowFactor))
  registry:add('input', InputService())
  registry:add('spriteMaker', SpriteMaker(eventBus, registry))
  registry:add('physics', PhysicsService(eventBus))

  stateSwitcher = StateSwitcher(registry, eventBus)
  eventBus:emit('setWindowFactor', windowFactor)
  eventBus:emit('switchState', 'initializeGame')
end

local lg = love.graphics

function love.draw()
  stateSwitcher:draw()
  lg.push()
  lg.origin()

  lg.setColor(0, 0, 0, 0.4)
  local w, h = lg.getWidth(), lg.getHeight()
  lg.rectangle('fill', 0, h - 20, w, h)

  lg.setColor(1, 1, 1)
  lg.print('FPS: ' .. love.timer.getFPS(), 0, h - 18)
  lg.print('Memory: ' .. math.floor(collectgarbage('count')) .. ' kb', 80, h - 18)

  lg.pop()
end

function love.update(dt)
  stateSwitcher:update(dt)
end

function love.quit()
  lily.quit()
  log.info('Quitting Surrender. Have a blessed day.')
end
