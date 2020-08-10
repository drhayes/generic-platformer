local Object = require 'lib.classic'

local Collider = Object:extend()

function Collider:collide(otherBody, collisionNormalX, collisionNormalY) end

return Collider
