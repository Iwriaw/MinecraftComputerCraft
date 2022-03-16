--get current path
path = fs.getDir(shell.getRunningProgram())
--load cturtle lib
assert(fs.exists(path..'/lib/cturtle.lua'), 
  'require ./lib/cturtle.lua'
)
dofile(path..'/lib/cturtle.lua')
--dfs chop
function dfsChop()
  local directionId = cturtle.directionEnum[cturtle.faceDirection]
  for i = 1, 6 do
    local id = (i - 2 + directionId) % 6 + 1
    local direction = cturtle.directionList[id]
    local hasBlock, blockInfo = cturtle.inspect(direction)
    if hasBlock then
      if blockInfo.tags['minecraft:logs'] then
        cturtle.forceMove(direction)
        dfsChop()
        cturtle.forceMove(cturtle.oppositeDirection[direction])
      end
    end
  end

end
--debug
dfsChop()
