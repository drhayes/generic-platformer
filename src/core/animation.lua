local Object = require 'lib.classic'
local anim8 = require 'lib.anim8'

local Animation = Object:extend()

local function getFrameName(imageRoot, index)
  return string.format(imageRoot .. '-%03d.png', index)
end

local function getAnimations(imageRoot, animData)
  local frameTags = animData.meta.frameTags
  local animations = {}
  for i = 1, #frameTags do
    local frameTag = frameTags[i]
    local anim = {
      from = frameTag.from,
      to = frameTag.to,
      direction = frameTag.direction,
      speeds = {}
    }
    local from = frameTag.from
    local to = frameTag.to
    if frameTag.direction == 'backward' then
      from = frameTag.to
      to = frameTag.from
    end
    for j = from, to do
      local singleFrame = getFrameName(imageRoot, j)
      table.insert(anim.speeds, animData.frames[singleFrame].duration)
    end
    animations[frameTag.name] = anim
  end
  log.debug(inspect(animations))
  error()
  return animations
end

function Animation:new(imageRoot, animationData)
  self.imageRoot = imageRoot
  -- What's our animation info like?
  local rawAnimData = animationData[imageRoot .. '-animation.json']
  if not rawAnimData then
    local mesg = 'animations not found for frame'
    log.error(mesg, imageRoot)
    error(mesg)
  end

  -- Get the durations.
  local durations = {}
  for name, frame in pairs(imageRoot.frames) do
    durations[name] = frame.duration
  end

  -- Get the frame tags.
  local animationSpecs = {}
  for i = 1, #rawAnimData.meta.frameTags do
    local frameTag = rawAnimData.meta.frameTags[i]
    local spec = {
      from = frameTag.from,
      to = frameTag.to,
      direction = frameTag.direction,
    }
    animationSpecs[frameTag.name] = spec
  end


  local animations = getAnimations(imageRoot, rawAnimData)
end

function Animation:update(dt)
end

function Animation:draw(x, y)
end

return Animation

--[[
local util = require 'core.util'
local lume = require 'lib.lume'
local anim8 = require 'lib.anim8'

local function mapFrameNames(name, indices)
  return lume.map(indices, function(i) return name .. i .. '.png' end)
end

local function range(from, to)
  local result = {}
  local step = lume.sign(to - from)
  for i = from, to, step do
    table.insert(result, i)
  end
  return result
end

return function(anim, spriteName)
  anim.currentName = anim.currentName or nil
  anim.current = anim.current or nil
  anim.all = anim.all or {}
  anim.done = anim.done or false

  local spriteAtlas = gameWorld.data.spriteAtlas

  -- Now to define the animations.
  for animName, animSpec in pairs(anim.all) do
    if not anim.currentName then
      anim.currentName = animName
    end
    if animSpec.staticFrame then
      local imageName = animSpec.staticFrame
      if not util.endsWith(imageName, '.png') then
        imageName = imageName .. '.png'
      end
      local frameData = { spriteAtlas.toQuad(imageName) }
      anim.all[animName] = anim8.newAnimation(frameData, 1)
    else
      local image = animSpec.image or animSpec.frameName or spriteName
      local frames = animSpec.frames
      if not frames and animSpec.frame then
        frames = { animSpec.frame }
      end
      if not frames and animSpec.range then
        frames = range(animSpec.range[1], animSpec.range[2])
      end
      if not frames and animSpec.numFrames then
        frames = range(0, animSpec.numFrames - 1)
      end
      local frameNames = mapFrameNames(image, frames)
      local speeds = animSpec.speed or animSpec.speeds or 1
      local after = animSpec.after
      local frameData = lume.map(frameNames, spriteAtlas.toQuad)
      if #frameData == 0 then
        error('hecking big error, no frame data for ' .. image .. ' with frames ' .. inspect(frames))
      end
      anim.all[animName] = anim8.newAnimation(frameData, speeds, after)
    end
  end

  if not anim.all[anim.currentName] and not anim.variableWidth.all[anim.currentName] then
    local newName = next(anim.all)
    log.warn('Bad default currentName for ' .. spriteName .. ': ' .. anim.currentName .. ' using: ' .. newName)
    anim.currentName = newName
  end
  if not anim.current then
    anim.current = anim.all[anim.currentName]
  end

  return anim
end

--]]
