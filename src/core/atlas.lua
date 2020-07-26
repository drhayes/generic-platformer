local Object = require 'lib.classic'
local RegionAttachment = require "spine-lua.attachments.RegionAttachment"
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


-- This method is being a decoy for this one from the Spine lua runtime:
-- AtlasAttachmentLoader:newRegionAttachment(skin, name, path)
-- But it depends on a yucky libgdx atlas format and I hate that, so
-- let's get it to use mine.
function Atlas:newRegionAttachment(_, name, path)
  path = path .. '.png'
  local attachment = RegionAttachment.new(name)
  local region = {
    page = nil,
    name = nil,
    x = 0,
    y = 0,
    index = 0,
    rotate = false,
    degrees = 0,
    texture = nil,
    renderObject = nil,
    u = 0, v = 0,
    u2 = 0, v2 = 0,
    width = 0, height = 0,
    offsetX = 0, offsetY = 0,
    originalWidth = 0, originalHeight = 0
  }
  -- wtf is this?
  region.renderObject = region

  local x, y, w, h = self.quads[path]:getViewport()
  region.page, region.name = name, name
  region.x, region.y = x, y
  region.index = -1 -- pretty much always...
  -- region.rotated = NOT ROTATING THINGS YET
  -- region.degrees = NOT ROTATING THINGS YET
  region.texture = self.image
  region.width, region.height = w, h
  region.originalWidth, region.originalHeight = w, h
  region.u, region.v = x / self.imageWidth, y / self.imageHeight
  region.u2, region.v2 = (x + w) / self.imageWidth, (y + h) / self.imageHeight

  attachment:setRegion(region)
  -- Didn't we just set it? wtf?
  attachment.region = region

  return attachment
end

function Atlas:toQuad(frameName)
  return self.quads[frameName]
end


return Atlas
