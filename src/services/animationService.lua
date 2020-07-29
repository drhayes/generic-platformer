local Object = require 'lib.classic'
local Animation = require 'core.animation'
local anim8 = require 'lib.anim8'

local AnimationService = Object:extend()

local function getFrameName(imageRoot, index)
  return string.format(imageRoot .. '-%03d.png', index)
end

function AnimationService:new(animationData, spriteAtlas)
  self.spriteAtlas = spriteAtlas
  self.imagesets = {}
  -- Separate into per-image-set animation data.
  for key, data in pairs(animationData) do
    local imageRoot = key:match('(%a+)-animation.json')
    local imageset = {}
    -- For each image, save the animations...
    local frameTags = data.meta.frameTags
    for i = 1, #frameTags do
      local frameTag = frameTags[i]
      local anim = {
        from = frameTag.from,
        to = frameTag.to,
        direction = frameTag.direction,
      }
      -- ..and the durations per-frame.
      anim.durations = {}
      for j = frameTag.from, frameTag.to do
        local frameName = getFrameName(imageRoot, j)
        table.insert(anim.durations, data.frames[frameName].duration / 1000)
      end
      imageset[frameTag.name] = anim
    end

    self.imagesets[imageRoot] = imageset
  end
end

function AnimationService:create(imageRoot)
  local spriteAtlas = self.spriteAtlas

  local animation = Animation(spriteAtlas)
  local imageset = self.imagesets[imageRoot]
  if not imageset then
    log.warn('No matching image root', imageRoot)
    return animation
  end

  -- Iterate the animations in the imageset...
  for name, data in pairs(imageset) do
    -- ...and make an anim8 instace for each one by first getting the quads...
    local quads = {}
    for i = data.from, data.to do
      local frameName = getFrameName(imageRoot, i)
      table.insert(quads, spriteAtlas:toQuad(frameName))
    end
    -- TODO: Oh yeah, looping happens in that 'nil' param.
    local animationInstance = anim8.newAnimation(quads, data.durations, nil)
    -- ...and add it to the animation instance.
    animation:add(name, animationInstance)
  end
  return animation
end

return AnimationService
