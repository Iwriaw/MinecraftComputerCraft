--get current path
path = fs.getDir(shell.getRunningProgram())
--load cturtle lib
assert(fs.exists(path..'/lib/cturtle.lua'), 
  'require ./lib/cturtle.lua'
)
dofile(path..'/lib/cturtle.lua')
position,reason = cturtle:getPositionByGps()
assert(position ~= nil, reason)
cturtle.position = position
faceDirection, reason = cturtle:getFaceDirectionByGps()
assert(faceDirection ~= nil, reason)
cturtle.faceDirection = faceDirection
--32 65 80
function flatten(nowPosition, nextPosition, direction)
  while cturtle:move('down') do end
  while cturtle.position.y < nowPosition.y do
    cturtle:move('up')
    while not cturtle:select('minecraft:dirt') do
      print('need dirt.')
      os.pullEvent('turtle_inventory')
    end
    cturtle:place('down')
  end
  while cturtle:detect('up') do
    cturtle:dig('up')
    cturtle:move('up')
  end
  while cturtle.position.y > nowPosition.y do
    cturtle:move('down')
  end
  cturtle:dig(direction)
end
cturtle:traverse(
  vector.new(32, 65, 80),
  vector.new(32 + 95, 65 , 95),
  flatten
)