return {
  player = {
    runVelocity = 50,
    jumpHeight = 20,
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
    },
  }
}
