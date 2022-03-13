--get current path
path = fs.getDir(shell.getRunningProgram())
--load cturtle lib
assert(fs.exists(path..'/lib/cturtle.lua'), 
  'require ./lib/cturtle.lua'
)
dofile(path..'/lib/cturtle.lua')

cturtle.faceDirection = 'east'
local blueprint = {}
function scan(nowPosition, nextPosition, direction)
  local exist, info = cturtle:inspect(direction)
  if exist then
    blueprint[tostring(nextPosition)] = {}
    blueprint[tostring(nextPosition)]['name'] = info.name
    blueprint[tostring(nextPosition)]['state'] = info.state
  end
  cturtle:dig(direction)
end
--building size
cuboid = vector.new(3,3,3)
cturtle:traverse(
  vector.new(1, 0, 0),
  vector.new(0, -1, -1) + cuboid,
  scan
)

file = io.open('test.blueprint', 'w')
file:write(textutils.serialize(blueprint))
file:close()