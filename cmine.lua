--get current path
path = fs.getDir(shell.getRunningProgram())
--load cturtle lib
assert(fs.exists(path..'/lib/cturtle.lua'), 
  'require ./lib/cturtle.lua'
)
dofile(path..'/lib/cturtle.lua')
--ore list
oreList = {
  'minecraft:coal_ore',
  'minecraft:deepslate_coal_ore',
  'minecraft:iron_ore',
  'minecraft:deepslate_iron_ore',
  'minecraft:copper_ore',
  'minecraft:deepslate_copper_ore',
  'minecraft:gold_ore',
  'minecraft:deepslate_gold_ore',
  'minecraft:redstone_ore',
  'minecraft:deepslate_redstone_ore',
  'minecraft:emerald_ore',
  'minecraft:deepslate_emerald_ore',
  'minecraft:lapis_ore',
  'minecraft:deepslate_lapis_ore',
  'minecraft:diamond_ore',
  'minecraft:deepslate_diamond_ore',
  'minecraft:nether_gold_ore',
  'minecraft:nether_quartz_ore',
  'minecraft:ancient_debris',
  'immersiveengineering:ore_aluminum',
  'immersiveengineering:deepslate_ore_aluminum',
  'immersiveengineering:ore_lead',
  'immersiveengineering:deepslate_ore_lead',
  'immersiveengineering:ore_silver',
  'immersiveengineering:deepslate_ore_silver',
  'immersiveengineering:ore_nickel',
  'immersiveengineering:deepslate_ore_nickel',
  'immersiveengineering:ore_uranium',
  'immersiveengineering:deepslate_ore_uranium'
}
function isOre(n)
  for _, oreName in pairs(oreList) do
    if n == oreName then
      return true
    end
  end
  return false
end
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
--dfs mine
function dfsMine()
  for id = 1, 6 do
    local direction = cturtle._moveDirectionList[id]
    local hasBlock, blockInfo = cturtle:inspect(direction)
    if hasBlock and isOre(blockInfo.name) then
      moveWhatever(direction)
      dfsMine()
      moveWhatever(cturtle:getOppositeDirection(direction))
    end
  end
end
--debug
length = 64
for _=1,length do
  moveWhatever('north')
  dfsMine()
end
for _=1,length do
  moveWhatever('south')
end
