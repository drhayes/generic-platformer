local Object = require 'lib.classic'
local lume = require 'lib.lume'

local Atlas = Object:extend()

function Atlas:new(json, image)
  self.image = image
  self.imageWidth, self.imageHeight = image:getDimensions()
  -- Keyed by image name, e.g. 'player-body.png'.
  self.quads = {}
  -- Keyed by image name, e.g. 'player-body.png'.
  self.sizes = {}
  -- Keyed by quad, i.e. love.graphics.newQuad things.
  self.trims = {}
  for name, frame in pairs(json.frames) do
    local x, y, w, h = frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h
    self.sizes[name] = { w = w, h = h }
    local quad = love.graphics.newQuad(x, y, w, h, self.imageWidth, self.imageHeight)
    self.quads[name] = quad
    if frame.trimmed then
      self.trims[quad] = {
        x = frame.spriteSourceSize.x,
        y = frame.spriteSourceSize.y,
        w = frame.sourceSize.w,
        h = frame.sourceSize.h
      }
    end
  end
  -- Bind the toQuad method so it can be passed to lume.map and stuff.
  self.toQuad = lume.fn(self.toQuad, self)
end

function Atlas:toQuad(frameName)
  return self.quads[frameName]
end


return Atlas
