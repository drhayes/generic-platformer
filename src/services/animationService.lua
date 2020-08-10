local Object = require 'lib.classic'
local Animation = require 'components.animation'
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
    local imageset = {
      anims = {},
      celData = {},
    }
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
      imageset.anims[frameTag.name] = anim
    end
    -- ...and make sure to grab that cel data.
    local layers = data.meta.layers
    if layers and layers[1] and layers[1].cels then
      for i = 1, #layers do
        local layer = layers[i]
        for j = 1, #layer.cels do
          local cel = layer.cels[j]
          local celData = imageset.celData[cel.frame]
          if not celData then
            celData = {}
            imageset.celData[cel.frame] = celData
          end
          table.insert(celData, cel.data)
        end
      end
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
  for name, data in pairs(imageset.anims) do
    -- ...and make an anim8 instace for each one by first getting the quads...
    local quads = {}
    for i = data.from, data.to do
      local frameName = getFrameName(imageRoot, i)
      table.insert(quads, spriteAtlas:toQuad(frameName))
    end
    local loopOperation = nil
    -- Does the "to" frame have any cel data that looks like a loop operation?
    local celData = imageset.celData[data.to]
    if celData then
      loopOperation = celData[1]
    end
    local animationInstance = anim8.newAnimation(quads, data.durations, loopOperation)
    -- ...and add it to the animation instance.
    animation:add(name, animationInstance)
  end
  return animation
end

return AnimationService
