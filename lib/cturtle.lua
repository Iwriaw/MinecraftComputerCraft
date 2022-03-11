cturtle = {}
--turtle faceDirection list
cturtle.faceDirectionList = {'north', 'east', 'south', 'west'}
--turtle faceDirection enum
cturtle.faceDirectionEnum = {}
cturtle.faceDirectionEnum['north'] = 1
cturtle.faceDirectionEnum['east'] = 2
cturtle.faceDirectionEnum['south'] = 3
cturtle.faceDirectionEnum['west'] = 4

--turtle direction enum
cturtle.directionList = {'north', 'east', 'south', 'west', 'up', 'down'}
--turtle direction enum
cturtle.directionEnum = {}
cturtle.directionEnum['north'] = 1
cturtle.directionEnum['east'] = 2
cturtle.directionEnum['south'] = 3
cturtle.directionEnum['west'] = 4
cturtle.directionEnum['up'] = 5
cturtle.directionEnum['down'] = 6
--turtle oppositeDirection enum
cturtle.oppositeDirection = {}
cturtle.oppositeDirection['north'] = 'south'
cturtle.oppositeDirection['south'] = 'north'
cturtle.oppositeDirection['east'] = 'west'
cturtle.oppositeDirection['west'] = 'east'
cturtle.oppositeDirection['up'] = 'down'
cturtle.oppositeDirection['down'] = 'up'
--turtle directionVector
cturtle.directionVector = {}
cturtle.directionVector['north'] = vector.new(0, 0, -1)
cturtle.directionVector['east'] = vector.new(1, 0, 0)
cturtle.directionVector['south'] = vector.new(0, 0, 1)
cturtle.directionVector['west'] = vector.new(-1, 0, 0)
cturtle.directionVector['up'] = vector.new(0, 1, 0)
cturtle.directionVector['down'] = vector.new(0, -1, 0)
--turtle side enum
cturtle.sideEnum = {}
cturtle.sideEnum['left'] = 1
cturtle.sideEnum['right'] = 2
--turtle position var, 0, 0, 0 as default
cturtle.position = vector.new()
--turtle faceDirection var, 'north' as default
cturtle.faceDirection = 'north'
--check whether val is vector
function cturtle:isVector(v)
  if type(v) == 'table' and
    type(v.x) == 'number' and
    type(v.y) == 'number' and
    type(v.z) == 'number'
  then
    return true
  end
  return false
end
--check whether val is direction
function cturtle:isdirection(d)
  if type(d) == 'string' and
    cturtle.directionEnum[d] ~= nil
  then
    return true
  end
  return false
end
--check whether val is faceDirection
function cturtle:isFaceDirection(d)
  if type(d) == 'string' and
    cturtle.faceDirectionEnum[d] ~= nil
  then
    return true
  end
  return false
end
--check whether val is side
function cturtle:isSide(s)
  if type(s) == 'string' and
    cturtle.sideEnum[s] ~= nil
  then
    return true
  end
  return false
end
--getOppositeDirection
function cturtle:getOppositeDirection(d)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  return cturtle.oppositeDirection[d]
end
--turtle vector to direction
function cturtle:vectorToDirection(v)
  for direction, vector in pairs(cturtle.directionVector) do
    if vector:equals(v) then
      return direction
    end
  end
  return nil, "can't find corresponding face direction"
end
--get turtle position by gps
function cturtle:getPositionByGps()
  local x, y, z = gps.locate()
  if x == nil then
    return nil, 'fail to get position by gps'
  end
  return vector.new(x, y, z)
end
--get face direction by gps
function cturtle:getFaceDirectionByGps()
  local nowPosition = cturtle:getPositionByGps()
  if nowPosition == nil then
    return nil, 'fail to get position by gps'
  end
  for _, direction in pairs(cturtle.faceDirectionList) do
    if cturtle:move(direction) then
      local newPosition = cturtle:getPositionByGps()
      if newPosition == nil then
        return nil, 'fail to get position by gps'
      end
      local diffPosition = newPosition - nowPosition
      local faceDirection = cturtle:vectorToDirection(diffPosition)
      cturtle:move(cturtle:getOppositeDirection(direction))
      return cturtle:getOppositeDirection(faceDirection)
    end
  end
  return nil, "don't have space to move"
end
--set turtle position
function cturtle:setPosition(v)
  assert(cturtle:isVector(v),
    'parameter 1 must be vector'
  )
  cturtle.position = v
end
--set turtle faceDirection
function cturtle:setFaceDirection(d)
  assert(cturtle:isFaceDirection(d),
    'parameter 1 must be faceDirection string'
  )
  cturtle.faceDirection = d
end
--turtle face
function cturtle:face(d)
  assert(cturtle:isFaceDirection(d),
    'parameter 1 must be faceDirection string'
  )
  local fromFaceDirectionId = cturtle.faceDirectionEnum[cturtle.faceDirection]
  local toFaceDirectionId = cturtle.faceDirectionEnum[d]
  local directionDiff = (toFaceDirectionId - fromFaceDirectionId)
  --calculate minium turn times to face d
  if directionDiff == -3 then
    directionDiff = 1
  end
  if directionDiff == 3 then
    directionDiff = -1
  end
  if directionDiff <= 0 then
    turnFunc = turtle.turnLeft
  else
    turnFunc = turtle.turnRight
  end
  directionDiff = math.abs(directionDiff)
  for _ = 1, directionDiff, 1 do
    turnFunc()
  end
  cturtle.faceDirection = d
end
--turtle move
function cturtle:move(d)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  local moveFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    moveFunc = turtle.forward
  end
  if d == 'up' then
    moveFunc = turtle.up
  end
  if d == 'down' then
    moveFunc = turtle.down
  end
  local success, reason = moveFunc()
  if success then
    cturtle:setPosition(cturtle.position + cturtle.directionVector[d])
  end
  return success, reason 
end
--force move to dest position
function cturtle:moveTo(v)
  assert(cturtle:isVector(v),
    'parameter 1 must be vector'
  )
  while cturtle.position.x < v.x and cturtle:move('east') do end
  while cturtle.position.x > v.x and cturtle:move('west') do end
  while cturtle.position.y < v.y and cturtle:move('up') do end
  while cturtle.position.y > v.y and cturtle:move('down') do end
  while cturtle.position.z < v.z and cturtle:move('south') do end
  while cturtle.position.z > v.z and cturtle:move('north') do end
  if cturtle.position == v then
    return true
  end
  return false
end
--turtle dig
function cturtle:dig(d, s)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  assert(s == nil or cturtle:isSide(s),
  'parameter 2 must be nil or side string'
  )
  local digFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    digFunc = turtle.dig
  end
  if d == 'up' then
    digFunc = turtle.digUp
  end
  if d == 'down' then
    digFunc = turtle.digDown
  end
  local success, reason = digFunc(s)
  return success, reason 
end
--dig... and move = force move
function cturtle:forceMove(d)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  local success = false
  local reason
  while not success do
    success, reason = cturtle:move(d)
    if not success then
      if reason == 'Movement obstructed' then
        cturtle:dig(d)
      else
        return success, reason
      end
    end
  end
  return success
end
--force move to dest position
function cturtle:forceMoveTo(v)
  assert(cturtle:isVector(v),
    'parameter 1 must be vector'
  )
  while cturtle.position.x < v.x and cturtle:forceMove('east') do end
  while cturtle.position.x > v.x and cturtle:forceMove('west') do end
  while cturtle.position.y < v.y and cturtle:forceMove('up') do end
  while cturtle.position.y > v.y and cturtle:forceMove('down') do end
  while cturtle.position.z < v.z and cturtle:forceMove('south') do end
  while cturtle.position.z > v.z and cturtle:forceMove('north') do end
  if cturtle.position == v then
    return true
  end
  return false
end
function cturtle:inRange(fromV, toV, v)
  assert(cturtle:isVector(fromV),
    'parameter 1 must be vector'
  )
  assert(cturtle:isVector(toV),
    'parameter 2 must be vector'
  )
  assert(cturtle:isVector(v),
    'parameter 3 must be vector'
  )
  local minV = vector.new()
  local maxV = vector.new()
  minV.x = math.min(fromV.x, toV.x)
  minV.y = math.min(fromV.y, toV.y)
  minV.z = math.min(fromV.z, toV.z)
  maxV.x = math.max(fromV.x, toV.x)
  maxV.y = math.max(fromV.y, toV.y)
  maxV.z = math.max(fromV.z, toV.z)
  if minV.x <= v.x and v.x <= maxV.x and
    minV.y <= v.y and v.y <= maxV.y and
    minV.z <= v.z and v.z <= maxV.z
  then
    return true
  end
  return false
end
-- force traverse the cuboid
function cturtle:forceTraverse(fromV, toV)
  assert(cturtle:isVector(fromV),
    'parameter 1 must be vector'
  )
  assert(cturtle:isVector(toV),
    'parameter 2 must be vector'
  )
  local directionList = {'east', 'west', 'south', 'north', 'up', 'down'}
  local visit = {}
  cturtle:forceMoveTo(fromV)
  visit[tostring(cturtle.position)] = true
  local finish = false
  while not finish do
    finish = true
    for _, direction in pairs(directionList) do
      local nextPosition = cturtle.position + cturtle.directionVector[direction]
      if visit[tostring(nextPosition)] == nil and cturtle:inRange(fromV, toV, nextPosition) then
        cturtle:forceMove(direction)
        visit[tostring(cturtle.position)] = true
        finish = false
        break
      end
    end
  end
end
--turtle place
function cturtle:place(d, s)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  assert(s == nil or type(s) == 'string',
    'parameter 2 must be nil or string'
  )
  local placeFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    placeFunc = turtle.place
  end
  if d == 'up' then
    placeFunc = turtle.placeUp
  end
  if d == 'down' then
    placeFunc = turtle.placeDown
  end
  local success, reason = placeFunc(s)
  return success, reason 
end
--turtle drop
function cturtle:drop(d, c)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  assert(0 <= c and c <= 64,
    'parameter 2 must between [0, 64]'
  )
  local dropFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    dropFunc = turtle.drop
  end
  if d == 'up' then
    dropFunc = turtle.dropUp
  end
  if d == 'down' then
    dropFunc = turtle.dropDown
  end
  local success, reason = dropFunc(c)
  return success, reason
end
--turtle detect
function cturtle:detect(d)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  local detectFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    detectFunc = turtle.detect
  end
  if d == 'up' then
    detectFunc = turtle.detectUp
  end
  if d == 'down' then
    detectFunc = turtle.detectDown
  end
  local success, reason = detectFunc()
  return success, reason
end
--turtle compare
function cturtle:compare(d)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  local compareFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    compareFunc = turtle.compare
  end
  if d == 'up' then
    compareFunc = turtle.compareUp
  end
  if d == 'down' then
    compareFunc = turtle.compareDown
  end
  local success, reason = compareFunc()
  return success, reason
end
--turtle attack
function cturtle:attack(d, s)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  assert(s == nil or cturtle:isSide(s),
  'parameter 2 must be nil or side string'
  )
  local attackFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    attackFunc = turtle.attack
  end
  if d == 'up' then
    attackFunc = turtle.attackUp
  end
  if d == 'down' then
    attackFunc = turtle.attackDown
  end
  local success, reason = attackFunc(s)
  return success, reason 
end
--turtle suck
function cturtle:suck(d, c)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  assert(0 <= c and c <= 64,
    'parameter 2 must between [0, 64]'
  )
  local suckFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    suckFunc = turtle.suck
  end
  if d == 'up' then
    suckFunc = turtle.suckUp
  end
  if d == 'down' then
    suckFunc = turtle.suckDown
  end
  local success, reason = suckFunc(c)
  return success, reason
end
--turtle inspect
function cturtle:inspect(d)
  assert(cturtle:isdirection(d),
    'parameter 1 must be direction string'
  )
  local inspectFunc
  if cturtle:isFaceDirection(d) then
    cturtle:face(d)
    inspectFunc = turtle.inspect
  end
  if d == 'up' then
    inspectFunc = turtle.inspectUp
  end
  if d == 'down' then
    inspectFunc = turtle.inspectDown
  end
  local success, reason = inspectFunc()
  return success, reason
end