local GameObject = require 'gobs.gameObject'
local collisionLayers = require 'physics.collisionLayers'
local config = require 'gameConfig'
local StateMachine = require 'components.stateMachine'

local LevelExitsCollider = require 'physics.levelExitsCollider'
local TreasureCollider = require 'physics.treasureCollider'
local UsableCollider = require 'physics.usableCollider'

local PlayerExitingLevelDoor = require 'sprites.playerStates.playerExitingLevelDoor'
local PlayerFalling = require 'sprites.playerStates.playerFalling'
local PlayerFallingDeath = require 'sprites.playerStates.playerFallingDeath'
local PlayerIntroFalling = require 'sprites.playerStates.playerIntroFalling'
local PlayerJumping = require 'sprites.playerStates.playerJumping'
local PlayerNormal = require 'sprites.playerStates.playerNormal'
local PlayerPresentsSword = require 'sprites.playerStates.playerPresentsSword'
local PlayerSpawning = require 'sprites.playerStates.playerSpawning'
local PlayerSwordSwing = require 'sprites.playerStates.playerSwordSwing'

local Sword = require 'sprites.sword'

local Player = GameObject:extend()

function Player:new(spec)
  Player.super.new(self, spec.x, spec.y)
  self.layer = 'player'
  self.isPlayer = true
  self.jumpForgivenessTimer = 0

  self.input = spec.inputService
  self.sound = spec.soundService

  self.animation = self:add(spec.animationService:create('player'))

  local body = spec.physicsService:newBody(spec.x, spec.y, 4, 10, 0, 3)
  body.gravityForce.y = (2 * config.player.jumpHeight) / math.pow(config.player.timeToJumpApex, 2)
  body.collisionLayers = collisionLayers.player
  body.collisionMask = collisionLayers.tilemap + collisionLayers.treasure + collisionLayers.usables + collisionLayers.levelExits
  body:addCollider(TreasureCollider(self))
  body:addCollider(UsableCollider(self))
  self.levelExitCollider = body:addCollider(LevelExitsCollider(self))
  self.body = self:add(body)

  local stateMachine = StateMachine()
  stateMachine:add('spawning', PlayerSpawning(self))
  stateMachine:add('introFalling', PlayerIntroFalling(self))
  stateMachine:add('normal', PlayerNormal(self))
  stateMachine:add('falling', PlayerFalling(self))
  stateMachine:add('fallingDeath', PlayerFallingDeath(self, spec.eventBus))
  stateMachine:add('jumping', PlayerJumping(self))
  stateMachine:add('exitingLevelDoor', PlayerExitingLevelDoor(self))
  stateMachine:add('presentSword', PlayerPresentsSword(self, spec.animationService:create('sword')))
  stateMachine:add('swingSword', PlayerSwordSwing(self))
  self.stateMachine = self:add(stateMachine)
end

function Player:setUseObject(obj)
  self.useObject = obj
end

function Player:pickUpTreasure(treasure)
  if treasure:is(Sword) then
    self.hasSword = true
    self.stateMachine:switch('presentSword')
  end
end

function Player:__tostring()
  return 'Player'
end

return Player
