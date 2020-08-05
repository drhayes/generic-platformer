return {
  player = {
    runVelocity = 65,
    jumpHeight = 40,
    timeToJumpApex = .3,
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
      'tilemap',
      'treasure',
    },
  },

  input = {
    mappings = {
      controls = {
        left = { 'key:left', 'key:a' },
        right = { 'key:right', 'key:d' },
        up = { 'key:up', 'key:w' },
        down = { 'key:down', 'key:s' },
        jump = { 'key:space' },
      },
      pairs = {
        move = { 'left', 'right', 'up', 'down' }
      },
    },
  },
}
