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
print(cturtle.position)
print(cturtle.faceDirection)