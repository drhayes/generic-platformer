-- Make some globals.
inspect = require 'lib.inspect' -- luacheck: ignore
log = require 'lib.log' -- luacheck: ignore
local config = require 'gameConfig'

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
end

function love.draw()
end

function love.update(dt)
end
