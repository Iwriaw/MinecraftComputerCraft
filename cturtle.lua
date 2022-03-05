cturtle = {}
ct = cturtle
--turtle faceDirection list
ct._faceDirectionList = {'north', 'east', 'south', 'west'}
--turtle faceDirection enum
ct._faceDirectionEnum = {}
ct._faceDirectionEnum['north'] = 0
ct._faceDirectionEnum['east'] = 1
ct._faceDirectionEnum['south'] = 2
ct._faceDirectionEnum['west'] = 3
--turtle moveDirection enum
ct._moveDirectionEnum = {}
ct._moveDirectionEnum['north'] = vector.new(0, 0, -1)
ct._moveDirectionEnum['east'] = vector.new(1, 0, 0)
ct._moveDirectionEnum['south'] = vector.new(0, 0, 1)
ct._moveDirectionEnum['west'] = vector.new(-1, 0, 0)
ct._moveDirectionEnum['up'] = vector.new(0, 1, 0)
ct._moveDirectionEnum['down'] = vector.new(0, -1, 0)
--turtle oppositeDirection enum
ct._oppositeDirection = {}
ct._oppositeDirection['north'] = 'south'
ct._oppositeDirection['south'] = 'north'
ct._oppositeDirection['east'] = 'west'
ct._oppositeDirection['west'] = 'east'
ct._oppositeDirection['up'] = 'down'
ct._oppositeDirection['down'] = 'up'
--turtle side enum
ct._sideEnum = {}
ct._sideEnum['left'] = 0
ct._sideEnum['right'] = 1
--turtle position var
ct._position = vector.new(0, 0, 0)
--turtle faceDirection var, 'north' as default
ct._faceDirection = 'north'
--check whether val is vector
function ct:_isVector(v)
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
function ct:isMoveDirection(d)
  if (
    type(d) == 'string' and
    ct._moveDirectionEnum[d] ~= nil
  ) then
    return true
  end
  return false
end

--check whether val is faceDirection
function ct:isFaceDirection(d)
  if (
    type(d) == 'string' and
    ct._faceDirectionEnum[d] ~= nil
  ) then
    return true
  end
  return false
end

--getOppositeDirection
function ct:getOppositeDirection(d)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  return ct._oppositeDirection[d]
end
--check whether val is side
function ct:isSide(s)
  if (
    type(s) == 'string' and
    ct._sideEnum[s] ~= nil
  ) then
    return true
  end
  return false
end

--get turtle position
function ct:getPosition()
  return ct._position
end
--set turtle position
function ct:setPosition(v)
  assert(ct:_isVector(v),
    'parameter 1 must be vector'
  )
  ct._position = v
end
--get turtle faceDirection
function ct:getFaceDirection()
  return ct._faceDirection
end
--set turtle faceDirection
function ct:setFaceDirection(d)
  assert(ct:isFaceDirection(d),
    'parameter 1 must be faceDirection string'
  )
  ct._faceDirection = d
end
--turtle face
function ct:face(d)
  assert(ct:isFaceDirection(d),
    'parameter 1 must be faceDirection string'
  )
  local fromFaceDirectionId = ct._faceDirectionEnum[ct._faceDirection]
  local toFaceDirectionId = ct._faceDirectionEnum[d]
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
  ct._faceDirection = d
end
--turtle move
function ct:move(d)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  local moveFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
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
    ct:setPosition(ct._position + ct._moveDirectionEnum[d])
  end
  return success, reason 
end
--turtle dig
function ct:dig(d, s)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  assert(s == nil or ct:isSide(s),
  'parameter 2 must be nil or side string'
  )
  local digFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
    digFunc = turtle.dig
  end
  if d == 'up' then
    digFunc = turtle.DigUp
  end
  if d == 'down' then
    digFunc = turtle.digDown
  end
  local success, reason = digFunc(s)
  return success, reason 
end
--turtle place
function ct:place(d, s)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  assert(s == nil or type(s) == 'string',
    'parameter 2 must be nil or string'
  )
  local placeFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
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
function ct:drop(d, c)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  assert(0 <= c and c <= 64,
    'parameter 2 must between [0, 64]'
  )
  local dropFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
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
function ct:detect(d)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  local detectFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
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
function ct:compare(d)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  local compareFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
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
function ct:attack(d, s)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  assert(s == nil or ct:isSide(s),
  'parameter 2 must be nil or side string'
  )
  local attackFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
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
function ct:suck(d, c)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  assert(0 <= c and c <= 64,
    'parameter 2 must between [0, 64]'
  )
  local suckFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
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
function ct:inspect(d)
  assert(ct:isMoveDirection(d),
    'parameter 1 must be moveDirection string'
  )
  local inspectFunc
  if ct:isFaceDirection(d) then
    ct:face(d)
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
--remove alias
ct = nil
