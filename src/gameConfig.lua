return {
  player = {
    runVelocity = 65,
    airVelocity = 50,
    jumpHeight = 40,
    timeToJumpApex = .3,
    jumpForgivenessThresholdSeconds = .2,
    fallingDeathVelocity = 600,
    jumpFloatTime = .5,
  },

  map = {
    tileSize = 16,
    start = 'entrance.lua',
  },

  graphics = {
    width = 400,
    height = 225,
    windowFactor = 4,
    maxWindowFactor = 6,
    uiScale = 2,
  },

  physics = {
    layers = {
      'player',
      'usables',
      'tilemap',
      'treasure',
      'levelExits',
    },
  },

  camera = {
    newRailSnapDelay = .1,
    lerpFactor = 0.05,
  },

  input = {
    mappings = {
      controls = {
        left = { 'key:left', 'key:a', 'axis:leftx-', 'button:dpleft' },
        right = { 'key:right', 'key:d', 'axis:leftx+', 'button:dpright' },
        up = { 'key:up', 'key:w', 'axis:lefty-', 'button:dpup' },
        down = { 'key:down', 'key:s', 'axis:lefty+', 'button:dpdown' },
        jump = { 'key:space', 'button:a' },
        action = { 'key:z', 'button:x' },
        cancel = { 'key:x', 'button:b' },
      },
      pairs = {
        move = { 'left', 'right', 'up', 'down' }
      },
    },
  },
}
