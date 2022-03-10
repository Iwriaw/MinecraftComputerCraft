--get current path
path = fs.getDir(shell.getRunningProgram())
--load cturtle lib
assert(fs.exists(path..'/lib/cturtle.lua'), 
  'require ./lib/cturtle.lua'
)
dofile(path..'/lib/cturtle.lua')

while true do
  cturtle:forceTraverse(
    vector.new(-36, 65, 112),
    vector.new(-46, 65, 94)
  )
  cturtle:forceMoveTo(
    vector.new(-36, 65, 103)
  )
  os.sleep(1200)
end