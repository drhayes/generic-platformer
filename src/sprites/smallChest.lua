local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'

local SmallChest = GameObject:extend()

function SmallChest:new(spec)
  self.x, self.y = spec.x, spec.y
  self.layer = 'background'
  self.eventBus = spec.eventBus

  self.animation = spec.animationService:create('smallChest')
  self.animation.current = 'closed'
  self.animation.animations.opening.doneOpening = function()
    self.animation.current = 'open'
    self.hasOpened = true
    self:spillRiches()
  end

  local body = spec.physicsService:newBody(self)
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 6
  body.aabb.halfSize.y = 6
  body.aabbOffset.x = 2
  body.aabbOffset.y = 4
  body.collisionLayers = collisionLayers.usables
  self.body = body

  self.isUsable = true
  self.hasOpened = false
end

function SmallChest:update(dt)
  self.body:update(dt)
  self.animation:update(dt)

  if self.goldCoroutine then
    local ok, message = coroutine.resume(self.goldCoroutine, dt)
    if not ok then
      error(message)
    end
  end
end

local lg = love.graphics

function SmallChest:draw()
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.animation:draw(self.x, self.y)
  lg.pop()
end

function SmallChest:used(user)
  self.isUsable = false
  self.animation.current = 'opening'
end

function SmallChest:spillRiches()
  local counter = 10
  local function spitGold()
    local wait = 5
    for i = 1, counter do
      while wait < .12 do
        wait = wait + coroutine.yield()
      end

      self.eventBus:emit('spawnSpriteByType', 'goldCoin', self.x, self.y)
      wait = 0
    end
    self.goldCoroutine = nil
  end

  self.goldCoroutine = coroutine.create(spitGold)
end

function SmallChest:__tostring()
  return 'SmallChest'
end

return SmallChest
