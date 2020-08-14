local Object = require 'lib.classic'
local ripple = require 'lib.ripple'

local SoundService = Object:extend()

function SoundService:new()
  self.sounds = {}
end

function SoundService:add(name, sound)
  self.sounds[name] = ripple.newSound(sound)
end

function SoundService:play(name)
  local sound = self.sounds[name]
  if not sound then
    log.error('Tried to play non-existent sound', name)
    return
  end

  sound:play()
end

return SoundService
