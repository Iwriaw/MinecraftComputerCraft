--get current path
path = fs.getDir(shell.getRunningProgram())
--load cturtle lib
assert(fs.exists(path..'/lib/cturtle.lua'), 
  'require ./lib/cturtle.lua'
)
dofile(path..'/lib/cturtle.lua')

--dfs chop
function dfsChop()
  local leaveId = {}
  local directionId = cturtle.directionEnum[cturtle.faceDirection]
  for i = 1, 6 do
    local id = (i - 2 + directionId) % 6 + 1
    local direction = cturtle.directionList[id]
    local hasBlock, blockInfo = cturtle:inspect(direction)
    if hasBlock then
      if blockInfo.tags['minecraft:logs'] then
        cturtle:forceMove(direction)
        dfsChop()
        cturtle:forceMove(cturtle:getOppositeDirection(direction))
      end
      if blockInfo.tags['minecraft:leaves'] then
        table.insert(leaveId, id)
      end
    end
  end
  for _, id in pairs(leaveId) do
    local direction = cturtle.directionList[id]
    local hasBlock, blockInfo = cturtle:inspect(direction)
    if not (hasBlock and blockInfo.tags['minecraft:leaves']) then
      return
    end
    cturtle:forceMove(direction)
    dfsChop()
    cturtle:forceMove(cturtle:getOppositeDirection(direction))
  end
end
--debug
dfsChop()
