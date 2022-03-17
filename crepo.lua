crepo = {}
function crepo.loadItemMapData()
  if fs.exists('item_map.data') then
    local itemMapData = io.open('item_map.data', 'r')
    crepo.itemMap = textutils.unserialize(itemMapData:read('*a'))
    itemMapData:close()
  else
    crepo.itemMap = {}
  end
end
function crepo.saveItemMapData()
  local itemMapData = io.open('item_map.data', 'w')
  itemMapData:write(textutils.serialize(crepo.itemMap))
  itemMapData:close()
end
function crepo.init()
  local inventoryList = {peripheral.find('inventory')}
  crepo.inventoryMap = {}
  for _, inventory in pairs(inventoryList) do
    local name = peripheral.getName(inventory)
    crepo.inventoryMap[name] = inventory
  end
  local inputName = 'immersiveengineer:woodencrate_66'
  local outputName = 'immersiveengineer:woodencrate_67'
  crepo.inputInventory = crepo.inventoryMap['']
  crepo.outputInventory = crepo.inventoryMap['right']
  crepo.inventoryMap['left'] = nil
  crepo.inventoryMap['right'] = nil
  crepo.loadItemMapData()
  for name, inventory in pairs(crepo.inventoryMap) do
    local itemList = inventory.list()
    for slot, itemInfo in pairs(itemList) do
      if crepo.itemMap[itemInfo.name] == nil then
        crepo.itemMap[itemInfo.name] = {}
        crepo.itemMap[itemInfo.name]['count'] = 0
        crepo.itemMap[itemInfo.name]['slots'] = {}
      end
      crepo.itemMap[itemInfo.name]['count'] = crepo.itemMap[itemInfo.name]['count'] + itemInfo.count
      local slotInfo = {}
      slotInfo['inventoryName'] = name
      slotInfo['slot'] = slot
      slotInfo['count'] = itemInfo.count
      table.insert(crepo.itemMap[itemInfo.name]['slots'], slotInfo)
    end
  end
end
--get empty slot
function crepo.getEmptySlot()
  for name, inventory in pairs(crepo.inventoryMap) do
    local itemList = inventory.list()
    if #itemList ~= inventory.size() then
      local slotInfo = {}
      slotInfo['inventoryName'] = name
      slotInfo['slot'] = #itemList + 1
      slotInfo['count'] = 0
      return slotInfo
    end
  end
  return nil
end
--store all items in inputInventory
function crepo.layIn()
  local itemList = crepo.inputInventory.list()
  for slot, itemInfo in pairs(itemList) do
    local name, count = itemInfo.name, itemInfo.count
    if crepo.itemMap[name] == nil then
      crepo.itemMap[name] = {}
      crepo.itemMap[name]['count'] = 0
      crepo.itemMap[name]['slots'] = {}
    end
    while count > 0 do
      local slots = crepo.itemMap[name]['slots']
      local lastSlot = slots[#slots]
      -- if lastSlot is full, find a new empty slot
      if lastSlot == nil or lastSlot.count == crepo.inventoryMap[lastSlot.inventoryName].getItemLimit(lastSlot.slot) then
        emptySlot = crepo.getEmptySlot()
        if emptySlot == nil then
          break
        end
        table.insert(slots, emptySlot)
        lastSlot = slots[#slots]
      end
      local layInCount = crepo.inputInventory.pushItems(lastSlot.inventoryName, slot, count, lastSlot.slot)
      if layInCount == 0 then
        if emptySlot == nil then
          break
        end
        table.insert(slots, emptySlot)
        lastSlot = slots[#slots]
      end
      print(name, '*', layInCount, ' to ', lastSlot.inventoryName, "'s ", lastSlot.slot, 'slot.')
      lastSlot.count = lastSlot.count + layInCount
      crepo.itemMap[name].count = crepo.itemMap[name].count + layInCount
      count = count - layInCount
    end
  end
  crepo.saveItemMapData()
end
function crepo.takeOut(name, count)
  if crepo.itemMap[name] == nil then
    return 0
  end
  local takeOutCount = 0
  while count > 0 do
    local slots = crepo.itemMap[name]['slots']
    local lastSlot = slots[#slots]
    -- if lastSlot's count is 0, del it.
    if lastSlot.count == 0 then
      table.remove(slots)
      lastSlot = slots[#slots]
      if lastSlot == nil then
        crepo.itemMap[name] = nil
        crepo.saveItemMapData()
        return takeOutCount
      end
    end
    local takeOutCount = crepo.outputInventory.pullItems(lastSlot.inventoryName, lastSlot.slot, count)
    lastSlot.count = lastSlot.count - takeOutCount
    crepo.itemMap[name].count = crepo.itemMap[name].count - takeOutCount
    count = count - takeOutCount
  end
  crepo.saveItemMapData()
  return takeOutCount
end
--debug
crepo.init()