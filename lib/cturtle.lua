cturtle = {}
--turtle faceDirection list
cturtle._faceDirectionList = {'north', 'east', 'south', 'west'}
--turtle faceDirection enum
cturtle._faceDirectionEnum = {}
cturtle._faceDirectionEnum['north'] = 0
cturtle._faceDirectionEnum['east'] = 1
cturtle._faceDirectionEnum['south'] = 2
cturtle._faceDirectionEnum['west'] = 3

--turtle moveDirection enum
cturtle._moveDirectionList = {'north', 'east', 'south', 'west', 'up', 'down'}
--turtle moveDirection enum
cturtle._moveDirectionEnum = {}
cturtle._moveDirectionEnum['north'] = vector.new(0, 0, -1)
cturtle._moveDirectionEnum['east'] = vector.new(1, 0, 0)
cturtle._moveDirectionEnum['south'] = vector.new(0, 0, 1)
cturtle._moveDirectionEnum['west'] = vector.new(-1, 0, 0)
cturtle._moveDirectionEnum['up'] = vector.new(0, 1, 0)
cturtle._moveDirectionEnum['down'] = vector.new(0, -1, 0)
--turtle oppositeDirection enum
cturtle._oppositeDirection = {}
cturtle._oppositeDirection['north'] = 'south'
cturtle._oppositeDirection['south'] = 'north'
cturtle._oppositeDirection['east'] = 'west'
cturtle._oppositeDirection['west'] = 'east'
cturtle._oppositeDirection['up'] = 'down'
cturtle._oppositeDirection['down'] = 'up'
--turtle side enum
cturtle._sideEnum = {}
cturtle._sideEnum['left'] = 0
cturtle._sideEnum['right'] = 1
--turtle position var
cturtle._position = vector.new(0, 0, 0)
--turtle faceDirection var, 'north' as default
cturtle._faceDirection = 'north'
--check whether val is vector
function cturtle:_isVector(v)
  if (
    type(v) == 'table' and
    type(v.x) == 'number' and
    type(v.y) == 'number' and
    type(v.z) == 'number'
  ) then
    return true
  end
  return false
end
--check whether val is moveDirection
function cturtle:isMoveDirection(d)
  if (
    type(d) == 'string' and
    cturtle._moveDirectionEnum[d] ~= nil
  ) then
    return true
  end
  return false
end

--check whether val is faceDirection
function cturtle:isFaceDirection(d)
  if (
    type(d) == 'string' and
    cturtle._faceDirectionEnum[d] ~= nil
  ) then
    return true
  end
  return false
end

--getOppositeDirection
function cturtle:getOppositeDirection(d)
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  return cturtle._oppositeDirection[d]
end
--check whether val is side
function cturtle:isSide(s)
  if (
    type(s) == 'string' and
    cturtle._sideEnum[s] ~= nil
  ) then
    return true
  end
  return false
end

--get turtle position
function cturtle:getPosition()
  return cturtle._position
end
--set turtle position
function cturtle:setPosition(v)
  assert(cturtle:_isVector(v),
    'parameter 1 must be vector'
  )
  cturtle._position = v
end
--get turtle faceDirection
function cturtle:getFaceDirection()
  return cturtle._faceDirection
end
--set turtle faceDirection
function cturtle:setFaceDirection(d)
  assert(cturtle:isFaceDirection(d),
    'parameter 1 must be faceDirection string'
  )
  cturtle._faceDirection = d
end
--turtle face
function cturtle:face(d)
  assert(cturtle:isFaceDirection(d),
    'parameter 1 must be faceDirection string'
  )
  local fromFaceDirectionId = cturtle._faceDirectionEnum[cturtle._faceDirection]
  local toFaceDirectionId = cturtle._faceDirectionEnum[d]
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
  cturtle._faceDirection = d
end
--turtle move
function cturtle:move(d)
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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
    cturtle:setPosition(cturtle._position + cturtle._moveDirectionEnum[d])
  end
  return success, reason 
end
--turtle dig
function cturtle:dig(d, s)
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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
--turtle place
function cturtle:place(d, s)
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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
  assert(cturtle:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
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