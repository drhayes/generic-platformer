local GameObject = require 'gobs.gameObject'

local Glimmer = GameObject:extend()

function Glimmer:new(x, y, width, height)
  Glimmer.super.new(self, x, y)
  self.layer = 'default'
  self.width, self.height = width, height
end

local lg = love.graphics
function Glimmer:draw()
  lg.push()
  lg.setColor(1, 1, 1, .3)
  lg.rectangle('fill', self.x, self.y, self.width, self.height)
  lg.pop()
end

return Glimmer
