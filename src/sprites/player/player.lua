local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'
local config = require 'gameConfig'
local TreasureCollider = require 'physics.treasureCollider'
local UsableCollider = require 'physics.usableCollider'
local StateMachine = require 'core.stateMachine'

local PlayerNormal = require 'sprites.player.playerNormal'
local PlayerSpawning = require 'sprites.player.playerSpawning'
local PlayerFalling = require 'sprites.player.playerFalling'
local PlayerJumping = require 'sprites.player.playerJumping'

local Player = GameObject:extend()

function Player:new(spec)
  self.x, self.y = spec.x, spec.y
  self.layer = 'player'
  self.isPlayer = true

  self.input = spec.inputService
  self.animation = spec.animationService:create('player')

  local body = spec.physicsService:newBody(self)
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 2
  body.aabb.halfSize.y = 5
  body.aabbOffset.y = 3
  body.gravityForce.y = (2 * config.player.jumpHeight) / math.pow(config.player.timeToJumpApex, 2)
  self.jumpVelocity = body.gravityForce.y * config.player.timeToJumpApex
  body.collisionLayers = collisionLayers.player
  body.collisionMask = collisionLayers.tilemap + collisionLayers.treasure + collisionLayers.usables
  self.body = body
  table.insert(body.colliders, TreasureCollider(self))
  table.insert(body.colliders, UsableCollider(self))

  local stateMachine = StateMachine()
  self.stateMachine = stateMachine
  stateMachine:add('spawning', PlayerSpawning(self))
  -- Depends on body in player.
  stateMachine:add('normal', PlayerNormal(self))
  stateMachine:add('falling', PlayerFalling(self))
  stateMachine:add('jumping', PlayerJumping(self))
end

function Player:update(dt)
  self.stateMachine:update(dt)
end

local lg = love.graphics

function Player:draw()
  lg.push()
  lg.setColor(1, 1, 1, 1)
  self.animation:draw(self.x, self.y)
  -- lg.setColor(0, 1, 0, .3)
  -- lg.rectangle('fill', self.body.aabb:bounds())
  lg.pop()
end

function Player:setUseObject(obj)
  self.useObject = obj
end

function Player:pickUpTreasure(treasure)
  log.debug('got treasure!')
  treasure.removeMe = true
end

function Player:__tostring()
  return 'Player'
end

return Player
