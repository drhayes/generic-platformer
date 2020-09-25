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
