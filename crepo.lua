require('ctable')
crepo = ctable.new()
function crepo.itemMapToInventoryMap(itemMap)
  itemMap = ctable.new()
  for itemName, itemStorage in pairs(itemMap) do
  end
end
function crepo.inventoryMapItemMap(inventoryMap)

end
--generate itemMap by scaning each inventory
function crepo.generateItemMap()
  crepo.itemMap = ctable.new()
  for name, inventory in pairs(crepo.inventories) do
    local itemList = inventory.list()
    for slot, itemInfo in pairs(itemList) do
      if crepo.itemMap[itemInfo.name] == nil then
        crepo.itemMap[itemInfo.name] = ctable.new()
        crepo.itemMap[itemInfo.name].count = 0
        crepo.itemMap[itemInfo.name].full = ctable.new()
        crepo.itemMap[itemInfo.name].notFull = ctable.new()
      end
      crepo.itemMap[itemInfo.name].count = crepo.itemMap[itemInfo.name].count + itemInfo.count
      local t = crepo.itemMap[itemInfo.name].full
      if itemInfo.count ~= inventory.getItemLimit(slot) then
        t = crepo.itemMap[itemInfo.name].notFull
      end
      if t[name] == nil then
        t[name] = ctable.new()
      end
      t[name][slot] = itemInfo.count
    end
  end
end
-- load itemMap from item_map.data or generate if the file doesn't exist.
function crepo.loadItemMap()
  if fs.exists('item_map.data') then
    local itemMapData = io.open('item_map.data', 'r')
    crepo.itemMap = textutils.unserialize(itemMapData:read('*a'))
    itemMapData:close()
  else
    crepo.generateItemMap()
  end
end
-- save itemMap to item_map.data
function crepo.saveItemMap()
  local itemMapData = io.open('item_map.data', 'w')
  itemMapData:write(textutils.serialize(crepo.itemMap))
  itemMapData:close()
end
-- init crepo
function crepo.init()
  local inventoryList = ctable.new({peripheral.find('inventory')})
  crepo.inventories = ctable.new()

  for _, inventory in pairs(inventoryList) do
    local name = peripheral.getName(inventory)
    crepo.inventories[name] = inventory

  end
  local inputName = 'immersiveengineering:woodencrate_68'
  local outputName = 'immersiveengineering:woodencrate_69'
  crepo.inputInventory = crepo.inventories[inputName]
  crepo.outputInventory = crepo.inventories[outputName]
  crepo.inventories[inputName] = nil
  crepo.inventories[outputName] = nil
  crepo.inventoryNameList = ctable.new()
  for inventoryName in pairs(crepo.inventories) do
    table.insert(crepo.inventoryNameList, inventoryName)
  end
  crepo.loadItemMap()
end
--get empty slot
crepo.getEmptySlotInventoryId = 1
function crepo.getEmptySlot()
  local inventoryNameListSize = #crepo.inventoryNameList
  for id = 1, inventoryNameListSize do
    print(crepo.getEmptySlotInventoryId)
    local inventoryName = crepo.inventoryNameList[crepo.getEmptySlotInventoryId]
    local inventory = crepo.inventories[inventoryName]
    local itemList = inventory.list()
    local itemListSize = #itemList
    if itemListSize ~= inventory.size() then
      return inventoryName, itemListSize + 1
    end
    crepo.getEmptySlotInventoryId = crepo.getEmptySlotInventoryId % inventoryNameListSize + 1
  end
  return nil
end
--store all items in inputInventory
function crepo.layIn()
  local itemList = crepo.inputInventory.list()
  for fromSlot, itemInfo in pairs(itemList) do
    local itemName = itemInfo.name
    local itemCount = itemInfo.count
    -- create data if don't have this item before
    if crepo.itemMap[itemName] == nil then
      crepo.itemMap[itemName] = ctable.new()
      crepo.itemMap[itemName].count = 0
      crepo.itemMap[itemName].full = ctable.new()
      crepo.itemMap[itemName].notFull = ctable.new()
    end
    while itemCount > 0 do
      --if don't have not full slot, find an empty slot
      if crepo.itemMap[itemName].notFull:empty() then
        local name, slot = crepo.getEmptySlot()
        if name == nil then
          break
        end
        if crepo.itemMap[itemName].notFull[name] == nil then
          crepo.itemMap[itemName].notFull[name] = ctable.new()
        end
        crepo.itemMap[itemName].notFull[name][slot] = 0
      end
      --traverse all not full slot and put items in
      for toName, toSlots in pairs(crepo.itemMap[itemName].notFull) do
        if itemCount == 0 then
          break
        end
        for toSlot, toSlotCount in pairs(toSlots) do
          if itemCount == 0 then
            break
          end
          local layInCount = crepo.inputInventory.pushItems(toName, fromSlot, itemCount, toSlot)
          print('lay in', layInCount)
          itemCount = itemCount - layInCount
          toSlots[toSlot] = toSlots[toSlot] + layInCount
          local slotLimit = crepo.inventories[toName].getItemDetail(toSlot).maxCount
          if toSlots[toSlot] == slotLimit then
            if crepo.itemMap[itemName].full[toName] == nil then
              crepo.itemMap[itemName].full[toName] = ctable.new()
            end
            crepo.itemMap[itemName].full[toName][toSlot] = toSlots[toSlot]
            toSlots[toSlot] = nil
            if toSlots:empty() then
              crepo.itemMap[itemName].notFull[toName] = nil
            end
          end
        end
      end
    end
  end
  crepo.saveItemMap()
end
--take out items from repository
function crepo.takeOut(itemName, itemCount)
  --return 0 if don't have this item

  while itemCount > 0 do
    print(itemCount)
    --if don't have not full slot, select an full slot
    if crepo.itemMap[itemName] == nil then
      break
    end
    if crepo.itemMap[itemName].notFull:empty() then
      if crepo.itemMap[itemName].full:empty() then
        break
      end
      for name, slots in pairs(crepo.itemMap[itemName].full) do
        for slot, count in pairs(slots) do
          print('move full to notFull')
          if crepo.itemMap[itemName].notFull[name] == nil then
            crepo.itemMap[itemName].notFull[name] = ctable.new()
          end
          crepo.itemMap[itemName].notFull[name][slot] = count
          crepo.itemMap[itemName].full[name][slot] = nil
          if crepo.itemMap[itemName].full[name]:empty() then
            crepo.itemMap[itemName].full[name] = nil
          end
          break
        end
        break
      end
    end
    --traverse all not full slot and take items out
    for fromName, fromSlots in pairs(crepo.itemMap[itemName].notFull) do
      if itemCount == 0 then
        break
      end
      for fromSlot, fromSlotCount in pairs(fromSlots) do
        if itemCount == 0 then
          break
        end
        local takeOutCount = crepo.outputInventory.pullItems(fromName, fromSlot, itemCount)
        itemCount = itemCount - takeOutCount
        print('get', itemCount)
        fromSlots[fromSlot] = fromSlots[fromSlot] - takeOutCount
        if fromSlots[fromSlot] == 0 then
          crepo.itemMap[itemName].notFull[fromName][fromSlot] = nil
          if crepo.itemMap[itemName].notFull[fromName]:empty() then
            crepo.itemMap[itemName].notFull[fromName] = nil
          end
        end
      end
    end
  end
  crepo.saveItemMap()
end
--debug
return crepo