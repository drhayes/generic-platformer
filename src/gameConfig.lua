return {
  player = {
    runVelocity = 65,
    airVelocity = 50,
    jumpHeight = 40,
    timeToJumpApex = .3,
    jumpForgivenessThresholdSeconds = .4,
    fallingDeathVelocity = 600,
  },

  map = {
    tileSize = 16,
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
    },
  },

  input = {
    mappings = {
      controls = {
        left = { 'key:left', 'key:a', 'axis:leftx-', 'button:dpleft' },
        right = { 'key:right', 'key:d', 'axis:leftx+', 'button:dpright' },
        up = { 'key:up', 'key:w', 'axis:lefty-', 'button:dpup' },
        down = { 'key:down', 'key:s', 'axis:lefty+', 'button:dpdown' },
        jump = { 'key:space', 'button:a' },
      },
      pairs = {
        move = { 'left', 'right', 'up', 'down' }
      },
    },
  },
}
