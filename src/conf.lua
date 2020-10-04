local config = require 'gameConfig'

function love.conf(t)
  t.window.title = config.title
  t.window.icon = 'media/images/icon.png'
  t.window.width = config.graphics.width * config.graphics.windowFactor
  t.window.height = config.graphics.height * config.graphics.windowFactor
  t.window.minwidth = config.graphics.width
  t.window.minheight = config.graphics.height
  t.window.resizable = true
  t.window.vsync = 1

  t.identity = config.identity
  t.version = '11.3'
  t.modules.physics = false
  t.modules.touch = false
  t.modules.video = false
end
