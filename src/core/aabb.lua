local Object = require 'lib.classic'
local Vector = require 'lib.brinevector'

local AABB = Object:extend()

function AABB:new(x, y, w, h)
  self.center = Vector(x, y)
  self.halfSize = Vector((w or 0) / 2, (h or 0) / 2)
end

-- Either pass in the other AABB,
-- or the center x,y and w,h of the rect.
function AABB:overlaps(x, y, w, h)
  if type(x) == 'table' and x:is(AABB) then
    local other = x
    if math.abs(self.center.x - other.center.x) >= self.halfSize.x + other.halfSize.x then
      return false
    end
    if math.abs(self.center.y - other.center.y) >= self.halfSize.y + other.halfSize.y then
      return false
    end
    return true
  else
    x = x - w / 2
    y = y - h / 2
    local left = self.center.x - self.halfSize.x
    local right = self.center.x + self.halfSize.x
    local top = self.center.y - self.halfSize.y
    local bottom = self.center.y + self.halfSize.y
    if right < x or left > x + w or bottom < y or top > y + h then return false end
    return true
  end
end

function AABB:bounds()
  return self.center.x - self.halfSize.x, self.center.y - self.halfSize.y,
    self.halfSize.x * 2, self.halfSize.y * 2
end

function AABB:left()
  return self.center.x - self.halfSize.x
end

function AABB:top()
  return self.center.y - self.halfSize.y
end

function AABB:right()
  return self.center.x + self.halfSize.x
end

function AABB:bottom()
  return self.center.y + self.halfSize.y
end

function AABB:width()
  return self.halfSize.x * 2
end

function AABB:height()
  return self.halfSize.y * 2
end

function AABB:isPointInside(x, y)
  if x < self:left() then return false end
  if x > self:right() then return false end
  if y < self:top() then return false end
  if y > self:bottom() then return false end
  return true
end

function AABB:projectionVector(other)
  return Vector(
    self.center.x - other.center.x + self.halfSize.x + other.halfSize.x,
    self.center.y - other.center.y + self.halfSize.y + other.halfSize.y
  )
end

function AABB:closestPointOnBoundsToPoint(point)
  local boundsPoint = Vector(self:left(), point.y)
  local minDist = math.abs(point.x - self:left())
  if math.abs(self:right() - point.x) < minDist then
    minDist = math.abs(self:right() - point.x)
    boundsPoint.x = self:right()
    boundsPoint.y = point.y
  end
  if math.abs(self:bottom() - point.y) < minDist then
    minDist = math.abs(self:bottom() - point.y)
    boundsPoint.x = point.x
    boundsPoint.y = self:bottom()
  end
  if math.abs(self:top() - point.y) < minDist then
    boundsPoint.x = point.x
    boundsPoint.y = self:top()
  end
  return boundsPoint
end

-- All this to prevent making another AABB instance, since I'm asuming this is used
-- in collision routines and will be making a lot of AABB instances; too much garbage!
function AABB:setMinkowskiDifference(a, b)
  local left = a:left() - b:right()
  local top = a:top() - b:bottom()
  local width = a:width() + b:width()
  local height = a:height() + b:height()

  self.center.x = left + width / 2
  self.center.y = top + height / 2
  self.halfSize.x = width / 2
  self.halfSize.y = height / 2
end

function AABB:isIntersectingOrigin()
  return self:left() < 0 and self:right() > 0 and self:top() < 0 and self:bottom() > 0
end

-- From https://blog.hamaluik.ca/posts/swept-aabb-collision-using-minkowski-difference/ .
-- For each of the AABB's four edges
-- calculate the minimum fraction of "direction"
-- in order to find where the ray FIRST intersects
-- the AABB (if it ever does).
function AABB:getRayIntersectionFraction(origin, direction)
  local ending = origin + direction

  -- Left side.
  local minT = self:getRayIntersectionFractionOfFirstRay(
    origin, ending,
    Vector(self:left(), self:top()), Vector(self:left(), self:bottom())
  )

  -- Bottom.
  local x = self:getRayIntersectionFractionOfFirstRay(
    origin, ending,
    Vector(self:left(), self:bottom()), Vector(self:right(), self:bottom())
  )
  if x < minT then minT = x end

  -- Right.
  x = self:getRayIntersectionFractionOfFirstRay(
    origin, ending,
    Vector(self:right(), self:bottom()), Vector(self:right(), self:top())
  )
  if x < minT then minT = x end

  -- Top.
  x = self:getRayIntersectionFractionOfFirstRay(
    origin, ending,
    Vector(self:right(), self:top()), Vector(self:left(), self:top())
  )
  if x < minT then minT = x end

  return minT
end

-- From https://blog.hamaluik.ca/posts/swept-aabb-collision-using-minkowski-difference/
-- Taken from https://github.com/pgkelley4/line-segments-intersect/blob/master/js/line-segments-intersect.js
-- which was adapted from http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
-- returns the point where they intersect (if they intersect)
-- returns Math.POSITIVE_INFINITY if they don't intersect
function AABB:getRayIntersectionFractionOfFirstRay(originA, endA, originB, endB)
  local r = endA - originA
  local s = endB - originB

  local numerator = (originB - originA) * r
  local denominator = r * s

  if numerator == 0 and denominator == 0 then
    return math.huge
  end

  if denominator == 0 then
    return math.huge
  end

  local u = numerator / denominator
  local t = ((originB - originA) * s) / denominator
  if t >= 0 and t <= 1 and u >= 0 and u <= 1 then
    return t
  end
  return math.huge
end

return AABB
