local Object = require 'lib.classic'

local FontService = Object:extend()

function FontService:new(eventBus)
  self.eventBus = eventBus
  self.fonts = {}
end

function FontService:add(name, font)
  self.fonts[name] = font
  if not self.defaultFont then
    self:setDefault(name)
  end
end

function FontService:get(name)
  if not name then return self.defaultFont end
  local font = self.fonts[name]
  if not font then
    log.warn('unknown font', name)
    return self.defaultFont
  end
  return font
end

function FontService:alias(oneName, anotherName)
  local font = self:get(oneName)
  self.fonts[anotherName] = font
end

function FontService:setDefault(name)
  local defaultFont = self.fonts[name]
  if not defaultFont then
    log.warn('No font by that name', name)
    return
  end
  self.defaultFont = defaultFont
  FontService.defaultFont = defaultFont
end

return FontService
