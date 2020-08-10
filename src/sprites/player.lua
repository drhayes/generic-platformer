local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'
local config = require 'gameConfig'
local TreasureCollider = require 'physics.treasureCollider'
local UsableCollider = require 'physics.usableCollider'
local StateMachine = require 'components.stateMachine'

local PlayerNormal = require 'sprites.playerStates.playerNormal'
local PlayerSpawning = require 'sprites.playerStates.playerSpawning'
local PlayerFalling = require 'sprites.playerStates.playerFalling'
local PlayerJumping = require 'sprites.playerStates.playerJumping'

local Player = GameObject:extend()

function Player:new(spec)
  Player.super.new(self, spec.x, spec.y)
  self.layer = 'player'
  self.isPlayer = true
  self.jumpForgivenessTimer = 0

  self.input = spec.inputService
  self.animation = self:add(spec.animationService:create('player'))

  local body = spec.physicsService:newBody()
  body.position.x, body.position.y = spec.x, spec.y
  body.aabb.center.x, body.aabb.center.y = spec.x, spec.y
  body.aabb.halfSize.x = 2
  body.aabb.halfSize.y = 5
  body.aabbOffset.y = 3
  body.gravityForce.y = (2 * config.player.jumpHeight) / math.pow(config.player.timeToJumpApex, 2)
  self.jumpVelocity = body.gravityForce.y * config.player.timeToJumpApex
  body.collisionLayers = collisionLayers.player
  body.collisionMask = collisionLayers.tilemap + collisionLayers.treasure + collisionLayers.usables
  table.insert(body.colliders, TreasureCollider(self))
  table.insert(body.colliders, UsableCollider(self))
  self.body = self:add(body)

  local stateMachine = StateMachine()
  stateMachine:add('spawning', PlayerSpawning(self))
  -- Depends on body in player.
  stateMachine:add('normal', PlayerNormal(self))
  stateMachine:add('falling', PlayerFalling(self, spec.eventBus))
  stateMachine:add('jumping', PlayerJumping(self))
  self:add(stateMachine)
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
