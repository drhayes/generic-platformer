local Object = require 'lib.classic'

local Collider = Object:extend()

function Collider:new(body)
  self.body = body
end

function Collider:collide(otherBody, collisionNormalX, collisionNormalY) end

return Collider
