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
function cturtle:isDirection(d)
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
--get vector distance
function cturtle:getVectorDistance(v1, v2)
  assert(cturtle:isVector(v1),
    'parameter 1 must be vector'
  )
  assert(v2 == nil or cturtle:isVector(v2),
    'parameter 2 must be nil or vector'
  )
  if v2 == nil then
    v2 = vector.new()
  end
  local diffVector = v1 - v2
  return math.abs(diffVector.x) + math.abs(diffVector.y) + math.abs(diffVector.z)
end
--vector to direction
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
      cturtle:move(cturtle.oppositeDirection[direction])
      return cturtle.oppositeDirection[faceDirection]
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
  assert(cturtle:isDirection(d),
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
function cturtle:moveTo(v, func)
  assert(cturtle:isVector(v),
    'parameter 1 must be vector'
  )
  assert(func == nil or type(func) == 'function',
    'parameter 2 must be nil or function'
  )
  if func == nil then
    func = function() end
  end
  local fuelLevel = turtle.getFuelLevel()
  local distance = cturtle:getVectorDistance(cturtle.position, v)
  if fuelLevel ~= 'unlimited' and fuelLevel < distance then
    return false, "don't have enough fuel to move"
  end
  while distance > 0 do
    for _, direction in pairs(cturtle.directionList) do
      local nextPosition = cturtle.position + cturtle.directionVector[direction]
      local nextDistance = cturtle:getVectorDistance(nextPosition, v)
      if nextDistance < distance then
        cturtle:face(direction)
        func(cturtle.position, nextPosition, direction)
        success, reason = cturtle:move(direction)
        if not success then
          return success, reason
        end
        distance = nextDistance
      end
    end
  end
  return true
end
--turtle dig
function cturtle:dig(d, s)
  assert(cturtle:isDirection(d),
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
  assert(cturtle:isDirection(d),
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
  local minV = vector.new(
    math.min(fromV.x, toV.x),
    math.min(fromV.y, toV.y),
    math.min(fromV.z, toV.z)
  )
  local maxV = vector.new(
    math.max(fromV.x, toV.x),
    math.max(fromV.y, toV.y),
    math.max(fromV.z, toV.z)
  )
  if minV.x <= v.x and v.x <= maxV.x and
    minV.y <= v.y and v.y <= maxV.y and
    minV.z <= v.z and v.z <= maxV.z
  then
    return true
  end
  return false
end
--traverse the cuboid
function cturtle:traverse(fromV, toV, func)
  assert(cturtle:isVector(fromV),
    'parameter 1 must be vector'
  )
  assert(cturtle:isVector(toV),
    'parameter 2 must be vector'
  )
  assert(func == nil or type(func) == 'function',
    'parameter 3 must be nil or function'
  )
  if func == nil then
    func = function() end
  end
  local fuelLevel = turtle.getFuelLevel()
  local diffVector = toV - fromV
  local distance = cturtle:getVectorDistance(cturtle.position, fromV)
  distance = distance + math.abs(diffVector.x * diffVector.y * diffVector.z) - 1
  if fuelLevel ~= 'unlimited' and fuelLevel < distance then
    return false, "don't have enough fuel to move"
  end
  local directionList = {'east', 'west', 'south', 'north', 'up', 'down'}
  local visit = {}
  cturtle:moveTo(fromV, func)
  visit[tostring(cturtle.position)] = true
  local finish = false
  while not finish do
    finish = true
    for _, direction in pairs(directionList) do
      local nextPosition = cturtle.position + cturtle.directionVector[direction]
      if visit[tostring(nextPosition)] == nil and cturtle:inRange(fromV, toV, nextPosition) then
        cturtle:face(direction)
        func(cturtle.position, nextPosition, direction)
        success, reason = cturtle:move(direction)
        if not success then
          return success, reason
        end
        visit[tostring(cturtle.position)] = true
        finish = false
        break
      end
    end
  end
  return true
end
--turtle place
function cturtle:place(d, s)
  assert(cturtle:isDirection(d),
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
  assert(cturtle:isDirection(d),
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
  assert(cturtle:isDirection(d),
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
  assert(cturtle:isDirection(d),
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
  assert(cturtle:isDirection(d),
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
  assert(cturtle:isDirection(d),
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
  assert(cturtle:isDirection(d),
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
--get turtle inventory item list
function cturtle:getItemList()
  local itemList = {}
    for slot = 1, 16 do
      itemList[slot] = turtle.getItemDetail(slot)
    end
  return itemList
end
--select specific item
function cturtle:select(name)
  local itemList = cturtle:getItemList()
  for slot, item in pairs(itemList) do
    if item.name == name then
      turtle.select(slot)
      return true
    end
  end
  return false
end