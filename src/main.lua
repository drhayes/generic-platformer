-- Make some globals.
inspect = require 'lib.inspect' -- luacheck: ignore
log = require 'lib.log' -- luacheck: ignore
local config = require 'gameConfig'
local EventEmitter = require 'core.eventEmitter'
local lily = require 'lib.lily'

local Registry = require 'services.registry'
local CheckpointService = require 'services.checkpointService'
local FontService = require 'services.fontService'
local InputService = require 'services.inputService'
local SpriteMaker = require 'services.spriteMakerService'
local PhysicsService = require 'services.physicsService'

local SceneManager = require 'scenes.sceneManager'
local InWorld = require 'scenes.inWorld'
local MainMenu = require 'scenes.mainMenu'
local PreloadGame = require 'scenes.preloadGame'
local InitializeGame = require 'scenes.initializeGame'
local sceneManager

local Camera = require 'core.camera'



function love.load()
  log.level = 'debug' -- luacheck: ignore

  log.info('Starting ' .. config.title .. '...')

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
  registry:add('checkpoint', CheckpointService(eventBus))
  registry:add('fonts', FontService(eventBus))
  registry:add('input', InputService())
  registry:add('spriteMaker', SpriteMaker(eventBus, registry))
  registry:add('physics', PhysicsService(eventBus))

  local camera = Camera(eventBus)

  sceneManager = SceneManager(camera)
  sceneManager:add('initializeGame', InitializeGame(registry, eventBus))
  sceneManager:add('preloadGame', PreloadGame(registry, eventBus))
  sceneManager:add('mainMenu', MainMenu(registry, eventBus))
  sceneManager:add('inWorld', InWorld(registry, eventBus))

  eventBus:emit('setWindowFactor', windowFactor)

  -- Let's get this show on the road.
  sceneManager:switch('initializeGame')
end

function love.draw()
  sceneManager:draw()
end

function love.update(dt)
  sceneManager:update(dt)
end

function love.keypressed(key, scancode, isRepeat)
  if key == 'f10' then
    love.graphics.captureScreenshot(os.date('%Y-%m-%d-%Hh-%Mm-%Ss.png')) -- luacheck: ignore
  elseif key == 'f9' then
    love.system.openURL('file://'..love.filesystem.getSaveDirectory())
  end
end


function love.quit()
  lily.quit()
  log.info('Quitting '.. config.title .. '. Have a day.')
end
