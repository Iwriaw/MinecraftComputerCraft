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
--debug
function dig(nowPosition, nextPosition, direction)
  cturtle:dig(direction)
end
while true do
  cturtle:traverse(
    vector.new(-36, 65, 112),
    vector.new(-46, 65, 94),
    dig
  )
  cturtle:moveTo(
    vector.new(-36, 65, 103),
    dig
  )
  os.sleep(1200)
end