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
-- valuable item list
valuableItemList = {
  'minecraft:coal',
  'minecraft:raw_iron',
  'minecraft:raw_copper',
  'minecraft:raw_gold',
  'minecraft:diamond',
  'minecraft:emerald',
  'minecraft:redstone',
  'minecraft:lapis_lazuli',
  'minecraft:quartz',
  'minecraft:gold_nugget',
  'minecraft:ancient_debris',
  'immersiveengineering:raw_aluninum',
  'immersiveengineering:raw_lead',
  'immersiveengineering:raw_silver',
  'immersiveengineering:raw_nickel',
  'immersiveengineering:raw_uranium'
}

--check whether n is ore's name
function isOre(n)
  for _, oreName in pairs(oreList) do
    if n == oreName then
      return true
    end
  end
  return false
end
--check whether n is valuable
function isValuable(n)
  for _, itemName in pairs(valuableItemList) do
    if n == itemName then
      return true
    end
  end
  return false
end
--dfs mine
function dfsMine()
  local directionId = cturtle.directionEnum[cturtle.faceDirection]
  for i = 1, 6 do
    local id = (i - 2 + directionId) % 6 + 1
    local direction = cturtle.directionList[id]
    local hasBlock, blockInfo = cturtle.inspect(direction)
    if hasBlock and isOre(blockInfo.name) then
      cturtle.forceMove(direction)
      dfsMine()
      cturtle.forceMove(cturtle.oppositeDirection[direction])
    end
  end
end
--clear backpack
function clearBackpack()
  for slot = 1, 16 do
    local itemInfo = turtle.getItemDetail(slot)
    if itemInfo ~= nil and not isValuable(itemInfo.name) then
      turtle.select(slot)
      turtle.drop(64)
    end
  end
end
--debug
loopTimes = 16
length = 65
for _ = 1, loopTimes do
  for _ = 1, length do
    cturtle.forceMove('west')
    dfsMine()
  end
  for _ = 1, length do
    cturtle.forceMove('east')
  end
  clearBackpack()
  for _ = 1, 5 do
    cturtle.forceMove('north')
    cturtle.dig('up')
    cturtle.dig('down')
  end
end