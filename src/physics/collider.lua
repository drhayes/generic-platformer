local Object = require 'lib.classic'

local Collider = Object:extend()

function Collider:new()
  self.enabled = true
end

function Collider:collide(otherBody, collisionNormalX, collisionNormalY) end

return Collider
