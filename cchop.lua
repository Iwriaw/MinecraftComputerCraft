--get current path
path = fs.getDir(shell.getRunningProgram())
--load cturtle lib
assert(fs.exists(path..'/lib/cturtle.lua'), 
  'require ./lib/cturtle.lua'
)
dofile(path..'/lib/cturtle.lua')
--move whatever
function moveWhatever(d)
  local success = false
  local reason
  while (not success) do
    success, reason = cturtle:move(d)
    if not success then
      if reason == 'Movement obstructed' then
        cturtle:dig(d)
      end
    end
  end
end
--dfs chop
function dfsChop()
  local leaveId = {}
  for id = 1, 6 do
    local direction = cturtle._moveDirectionList[id]
    local hasBlock, blockInfo = cturtle:inspect(direction)
    if hasBlock then
      if blockInfo.tags['minecraft:logs'] then
        moveWhatever(direction)
        dfsChop()
        moveWhatever(cturtle:getOppositeDirection(direction))
      end
      if blockInfo.tags['minecraft:leaves'] then
        table.insert(leaveId, id)
      end
    end
  end
  for _, id in pairs(leaveId) do
    local hasBlock, blockInfo = cturtle:inspect(direction)
    if not (hasBlock and blockInfo.tags['minecraft:leaves']) then
      return
    end
      local direction = cturtle._moveDirectionList[id]
    moveWhatever(direction)
    dfsChop()
    moveWhatever(cturtle:getOppositeDirection(direction))
  end
end
--debug
dfsChop()
